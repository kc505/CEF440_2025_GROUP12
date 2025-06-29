const express = require("express")
const router = express.Router()
const { body, validationResult, param } = require("express-validator")
const Session = require("../models/session")
const AttendanceRecord = require("../models/attendanceRecord")
const Course = require("../models/Course")
const User = require("../models/User")
const { requireRole } = require("../middleware/auth")
const { reverseGeocode, calculateDistance } = require("../services/locationService")
const { notifyStudents } = require("../services/notificationService")

// Create a new session (Lecturer only)
router.post(
  "/create",
  requireRole(["lecturer"]),
  [
    body("courseId").isUUID().withMessage("Valid course ID is required"),
    body("title")
      .trim()
      .isLength({ min: 1, max: 255 })
      .withMessage("Title is required and must be less than 255 characters"),
    body("description").optional().trim().isLength({ max: 1000 }),
    body("scheduledDate").isISO8601().withMessage("Valid date is required"),
    body("startTime")
      .matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/)
      .withMessage("Valid start time is required (HH:MM)"),
    body("endTime")
      .matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/)
      .withMessage("Valid end time is required (HH:MM)"),
    body("duration").isInt({ min: 1, max: 480 }).withMessage("Duration must be between 1 and 480 minutes"),
    body("geofenceLatitude").isDecimal().withMessage("Valid latitude is required"),
    body("geofenceLongitude").isDecimal().withMessage("Valid longitude is required"),
    body("geofenceRadius")
      .isInt({ min: 10, max: 500 })
      .withMessage("Geofence radius must be between 10 and 500 meters"),
    body("requiresFaceRecognition").optional().isBoolean(),
    body("allowLateEntry").optional().isBoolean(),
    body("lateEntryMinutes").optional().isInt({ min: 0, max: 60 }),
  ],
  async (req, res) => {
    try {
      // Check validation errors
      const errors = validationResult(req)
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: "Validation failed",
          errors: errors.array(),
        })
      }

      const {
        courseId,
        title,
        description,
        scheduledDate,
        startTime,
        endTime,
        duration,
        geofenceLatitude,
        geofenceLongitude,
        geofenceRadius,
        requiresFaceRecognition = true,
        allowLateEntry = false,
        lateEntryMinutes = 0,
      } = req.body

      // Verify lecturer owns/teaches the course
      const course = await Course.findOne({
        where: {
          id: courseId,
          lecturerId: req.user.id,
        },
      })

      if (!course) {
        return res.status(403).json({
          success: false,
          message: "You are not authorized to create sessions for this course",
        })
      }

      // Validate time logic
      const start = new Date(`1970-01-01T${startTime}:00`)
      const end = new Date(`1970-01-01T${endTime}:00`)
      const timeDiffMinutes = (end - start) / (1000 * 60)

      if (timeDiffMinutes !== duration) {
        return res.status(400).json({
          success: false,
          message: "Duration does not match the time difference between start and end time",
        })
      }

      // Get address from coordinates (reverse geocoding)
      let geofenceAddress = ""
      try {
        geofenceAddress = await reverseGeocode(geofenceLatitude, geofenceLongitude)
      } catch (error) {
        console.log("Reverse geocoding failed:", error.message)
        geofenceAddress = `${geofenceLatitude}, ${geofenceLongitude}`
      }

      // Get enrolled students count
      const enrolledStudents = await course.getStudents()
      const totalStudentsEnrolled = enrolledStudents.length

      // Create session
      const session = await Session.create({
        courseId,
        lecturerId: req.user.id,
        title,
        description,
        scheduledDate,
        startTime,
        endTime,
        duration,
        geofenceLatitude,
        geofenceLongitude,
        geofenceRadius,
        geofenceAddress,
        requiresFaceRecognition,
        allowLateEntry,
        lateEntryMinutes: allowLateEntry ? lateEntryMinutes : 0,
        totalStudentsEnrolled,
        createdBy: req.user.id,
      })

      // Create attendance records for all enrolled students (initially absent)
      const attendanceRecords = enrolledStudents.map((student) => ({
        sessionId: session.id,
        studentId: student.id,
        status: "Absent",
      }))

      await AttendanceRecord.bulkCreate(attendanceRecords)

      // Activate session immediately (makes attendance available)
      await session.update({
        status: "active",
        activatedAt: new Date(),
      })

      // Notify all enrolled students
      try {
        await notifyStudents(enrolledStudents, {
          type: "session_created",
          title: "New Session Available",
          message: `${course.code}: ${title} - Attendance is now open`,
          sessionId: session.id,
          courseId: course.id,
        })
      } catch (notificationError) {
        console.error("Failed to send notifications:", notificationError)
        // Don't fail the session creation if notifications fail
      }

      // Fetch the complete session data with associations
      const completedSession = await Session.findByPk(session.id, {
        include: [
          {
            model: Course,
            attributes: ["id", "code", "name"],
          },
          {
            model: User,
            as: "lecturer",
            attributes: ["id", "firstName", "lastName", "email"],
          },
        ],
      })

      res.status(201).json({
        success: true,
        message: "Session created successfully and attendance is now active",
        data: {
          session: completedSession,
          enrolledStudentsCount: totalStudentsEnrolled,
          geofenceInfo: {
            latitude: geofenceLatitude,
            longitude: geofenceLongitude,
            radius: geofenceRadius,
            address: geofenceAddress,
          },
        },
      })
    } catch (error) {
      console.error("Error creating session:", error)
      res.status(500).json({
        success: false,
        message: "Failed to create session",
        error: process.env.NODE_ENV === "development" ? error.message : "Internal server error",
      })
    }
  },
)

// Check if student can take attendance (geofence + session status check)
router.post(
  "/:sessionId/check-attendance-eligibility",
  requireRole(["student"]),
  [
    param("sessionId").isUUID().withMessage("Valid session ID is required"),
    body("latitude").isDecimal().withMessage("Valid latitude is required"),
    body("longitude").isDecimal().withMessage("Valid longitude is required"),
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req)
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: "Validation failed",
          errors: errors.array(),
        })
      }

      const { sessionId } = req.params
      const { latitude, longitude } = req.body

      const session = await Session.findByPk(sessionId)

      if (!session) {
        return res.status(404).json({
          success: false,
          message: "Session not found",
        })
      }

      // Check if student is enrolled
      const attendanceRecord = await AttendanceRecord.findOne({
        where: {
          sessionId: session.id,
          studentId: req.user.id,
        },
      })

      if (!attendanceRecord) {
        return res.status(403).json({
          success: false,
          message: "You are not enrolled in this course",
        })
      }

      // Check if already marked present
      if (attendanceRecord.status === "Present") {
        return res.status(400).json({
          success: false,
          message: "Attendance already recorded",
          data: {
            alreadyMarked: true,
            checkInTime: attendanceRecord.checkInTime,
            status: attendanceRecord.status,
          },
        })
      }

      // Check if session allows attendance
      const canTakeAttendance = session.canTakeAttendance()
      if (!canTakeAttendance) {
        return res.status(400).json({
          success: false,
          message: "Attendance is not currently available for this session",
          data: {
            sessionStatus: session.status,
            canTakeAttendance: false,
          },
        })
      }

      // Check geofence and calculate distance
      const distance = calculateDistance(latitude, longitude, session.geofenceLatitude, session.geofenceLongitude)
      const isWithinGeofence = distance <= session.geofenceRadius

      res.json({
        success: true,
        data: {
          canTakeAttendance: true,
          isWithinGeofence,
          distance: Math.round(distance),
          geofenceRadius: session.geofenceRadius,
          requiresFaceRecognition: session.requiresFaceRecognition,
          sessionInfo: {
            title: session.title,
            status: session.status,
            allowLateEntry: session.allowLateEntry,
          },
        },
      })
    } catch (error) {
      console.error("Error checking attendance eligibility:", error)
      res.status(500).json({
        success: false,
        message: "Failed to check attendance eligibility",
        error: process.env.NODE_ENV === "development" ? error.message : "Internal server error",
      })
    }
  },
)

// Mark attendance (geofence + face recognition)
router.post(
  "/:sessionId/mark-attendance",
  requireRole(["student"]),
  [
    param("sessionId").isUUID().withMessage("Valid session ID is required"),
    body("latitude").isDecimal().withMessage("Valid latitude is required"),
    body("longitude").isDecimal().withMessage("Valid longitude is required"),
    body("faceRecognitionScore").optional().isDecimal({ min: 0, max: 1 }),
    body("faceImageUrl").optional().isURL(),
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req)
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: "Validation failed",
          errors: errors.array(),
        })
      }

      const { sessionId } = req.params
      const { latitude, longitude, faceRecognitionScore, faceImageUrl } = req.body

      const session = await Session.findByPk(sessionId)

      if (!session) {
        return res.status(404).json({
          success: false,
          message: "Session not found",
        })
      }

      // Get attendance record
      const attendanceRecord = await AttendanceRecord.findOne({
        where: {
          sessionId: session.id,
          studentId: req.user.id,
        },
      })

      if (!attendanceRecord) {
        return res.status(403).json({
          success: false,
          message: "You are not enrolled in this course",
        })
      }

      // Check if already marked present
      if (attendanceRecord.status === "Present") {
        return res.status(400).json({
          success: false,
          message: "Attendance already recorded",
          data: {
            checkInTime: attendanceRecord.checkInTime,
            status: attendanceRecord.status,
          },
        })
      }

      // Check if session allows attendance
      if (!session.canTakeAttendance()) {
        return res.status(400).json({
          success: false,
          message: "Attendance is not currently available for this session",
        })
      }

      // Calculate distance and check geofence
      const distance = calculateDistance(latitude, longitude, session.geofenceLatitude, session.geofenceLongitude)

      if (distance > session.geofenceRadius) {
        return res.status(400).json({
          success: false,
          message: "You are not within the required location for this session",
          data: {
            distance: Math.round(distance),
            requiredRadius: session.geofenceRadius,
            isWithinGeofence: false,
          },
        })
      }

      // Check face recognition if required
      if (session.requiresFaceRecognition && (!faceRecognitionScore || faceRecognitionScore < 0.7)) {
        return res.status(400).json({
          success: false,
          message: "Face recognition verification failed or score too low",
          data: {
            requiresFaceRecognition: true,
            minimumScore: 0.7,
            providedScore: faceRecognitionScore,
          },
        })
      }

      // Mark attendance as present
      await attendanceRecord.markPresent(latitude, longitude, distance, faceRecognitionScore, faceImageUrl)

      // Update session attendance statistics
      await session.updateAttendanceStats()

      res.json({
        success: true,
        message: "Attendance marked successfully",
        data: {
          status: "Present",
          checkInTime: attendanceRecord.checkInTime,
          distance: Math.round(distance),
          faceRecognitionScore: faceRecognitionScore,
          sessionInfo: {
            title: session.title,
            attendanceCount: session.attendanceCount,
            totalStudents: session.totalStudentsEnrolled,
          },
        },
      })
    } catch (error) {
      console.error("Error marking attendance:", error)
      res.status(500).json({
        success: false,
        message: "Failed to mark attendance",
        error: process.env.NODE_ENV === "development" ? error.message : "Internal server error",
      })
    }
  },
)

// Get session attendance records (Lecturer only)
router.get(
  "/:sessionId/attendance",
  requireRole(["lecturer"]),
  param("sessionId").isUUID().withMessage("Valid session ID is required"),
  async (req, res) => {
    try {
      const errors = validationResult(req)
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: "Validation failed",
          errors: errors.array(),
        })
      }

      const { sessionId } = req.params

      const session = await Session.findOne({
        where: {
          id: sessionId,
          lecturerId: req.user.id,
        },
      })

      if (!session) {
        return res.status(404).json({
          success: false,
          message: "Session not found or you are not authorized",
        })
      }

      const attendanceRecords = await AttendanceRecord.findAll({
        where: { sessionId: session.id },
        include: [
          {
            model: User,
            as: "student",
            attributes: ["id", "firstName", "lastName", "email", "studentId"],
          },
        ],
        order: [
          ["status", "DESC"],
          ["checkInTime", "ASC"],
        ],
      })

      const attendanceStats = {
        totalStudents: session.totalStudentsEnrolled,
        presentCount: attendanceRecords.filter((record) => record.status === "Present").length,
        absentCount: attendanceRecords.filter((record) => record.status === "Absent").length,
        attendanceRate: session.attendanceRate,
      }

      res.json({
        success: true,
        data: {
          session: {
            id: session.id,
            title: session.title,
            status: session.status,
            scheduledDate: session.scheduledDate,
            startTime: session.startTime,
            endTime: session.endTime,
          },
          attendanceRecords,
          stats: attendanceStats,
        },
      })
    } catch (error) {
      console.error("Error fetching attendance records:", error)
      res.status(500).json({
        success: false,
        message: "Failed to fetch attendance records",
        error: process.env.NODE_ENV === "development" ? error.message : "Internal server error",
      })
    }
  },
)

// Manual attendance override (Lecturer only)
router.put(
  "/:sessionId/attendance/:studentId/override",
  requireRole(["lecturer"]),
  [
    param("sessionId").isUUID().withMessage("Valid session ID is required"),
    param("studentId").isUUID().withMessage("Valid student ID is required"),
    body("status").isIn(["Present", "Absent"]).withMessage("Status must be Present or Absent"),
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req)
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: "Validation failed",
          errors: errors.array(),
        })
      }

      const { sessionId, studentId } = req.params
      const { status } = req.body

      // Verify lecturer owns the session
      const session = await Session.findOne({
        where: {
          id: sessionId,
          lecturerId: req.user.id,
        },
      })

      if (!session) {
        return res.status(404).json({
          success: false,
          message: "Session not found or you are not authorized",
        })
      }

      // Find attendance record
      const attendanceRecord = await AttendanceRecord.findOne({
        where: {
          sessionId: sessionId,
          studentId: studentId,
        },
      })

      if (!attendanceRecord) {
        return res.status(404).json({
          success: false,
          message: "Attendance record not found",
        })
      }

      // Apply manual override
      await attendanceRecord.manualOverride(status, req.user.id)

      // Update session statistics
      await session.updateAttendanceStats()

      res.json({
        success: true,
        message: "Attendance status updated successfully",
        data: {
          attendanceRecord: {
            id: attendanceRecord.id,
            status: attendanceRecord.status,
            isManualOverride: attendanceRecord.isManualOverride,
            overrideAt: attendanceRecord.overrideAt,
          },
          sessionStats: {
            attendanceCount: session.attendanceCount,
            attendanceRate: session.attendanceRate,
          },
        },
      })
    } catch (error) {
      console.error("Error updating attendance:", error)
      res.status(500).json({
        success: false,
        message: "Failed to update attendance",
        error: process.env.NODE_ENV === "development" ? error.message : "Internal server error",
      })
    }
  },
)

// Complete session
router.put(
  "/:sessionId/complete",
  requireRole(["lecturer"]),
  param("sessionId").isUUID().withMessage("Valid session ID is required"),
  async (req, res) => {
    try {
      const errors = validationResult(req)
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: "Validation failed",
          errors: errors.array(),
        })
      }

      const { sessionId } = req.params

      const session = await Session.findOne({
        where: {
          id: sessionId,
          lecturerId: req.user.id,
        },
      })

      if (!session) {
        return res.status(404).json({
          success: false,
          message: "Session not found or you are not authorized",
        })
      }

      await session.update({
        status: "completed",
        completedAt: new Date(),
        updatedBy: req.user.id,
      })

      // Update attendance statistics
      await session.updateAttendanceStats()

      res.json({
        success: true,
        message: "Session completed successfully",
        data: {
          session,
          attendanceStats: {
            attendanceCount: session.attendanceCount,
            totalStudents: session.totalStudentsEnrolled,
            attendanceRate: session.attendanceRate,
          },
        },
      })
    } catch (error) {
      console.error("Error completing session:", error)
      res.status(500).json({
        success: false,
        message: "Failed to complete session",
        error: process.env.NODE_ENV === "development" ? error.message : "Internal server error",
      })
    }
  },
)

module.exports = router
