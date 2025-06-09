const { v4: uuidv4 } = require("uuid")
const { collections } = require("../config/firebase")
const { ApiError } = require("../utils/apiError")

/**
 * Create a new attendance session
 * @route POST /sessions
 */
const createSession = async (req, res, next) => {
  try {
    const { uid } = req.user

    // Check if user is a lecturer
    const lecturerDoc = await collections.lecturers.doc(uid).get()
    if (!lecturerDoc.exists) {
      throw new ApiError(403, "Only lecturers can create sessions")
    }

    const {
      courseId,
      sessionDate,
      startTime,
      endTime,
      sessionType,
      locationDescription,
      expectedAttendance,
      sessionNotes,
      materials,
      isRecurring,
      recurringPattern,
      geofenceData,
    } = req.body

    // Check if course exists
    const courseDoc = await collections.courses.doc(courseId).get()
    if (!courseDoc.exists) {
      throw new ApiError(404, "Course not found")
    }

    const courseData = courseDoc.data()

    // Check if user is the lecturer of the course
    if (courseData.lecturerId !== uid) {
      throw new ApiError(403, "You do not have permission to create sessions for this course")
    }

    // Check if there's an overlapping active session for the same course
    const overlappingSessionsSnapshot = await collections.courseSessions
      .where("courseId", "==", courseId)
      .where("sessionDate", "==", sessionDate)
      .where("sessionStatus", "in", ["SCHEDULED", "OPEN"])
      .get()

    for (const doc of overlappingSessionsSnapshot.docs) {
      const session = doc.data()

      // Check for time overlap
      const sessionStart = new Date(`${sessionDate}T${startTime}`)
      const sessionEnd = new Date(`${sessionDate}T${endTime}`)
      const existingStart = new Date(`${sessionDate}T${session.startTime}`)
      const existingEnd = new Date(`${sessionDate}T${session.endTime}`)

      if (
        (sessionStart >= existingStart && sessionStart < existingEnd) ||
        (sessionEnd > existingStart && sessionEnd <= existingEnd) ||
        (sessionStart <= existingStart && sessionEnd >= existingEnd)
      ) {
        throw new ApiError(409, "There is already an active session for this course at the specified time")
      }
    }

    // Create geofence location if provided
    let geofenceId = null
    if (geofenceData) {
      geofenceId = uuidv4()
      const geofenceLocation = {
        geofenceId,
        centerLatitude: geofenceData.centerLatitude,
        centerLongitude: geofenceData.centerLongitude,
        radiusInMeters: geofenceData.radiusInMeters || 50,
        locationName: geofenceData.locationName || locationDescription,
        building: geofenceData.building || "",
        floor: geofenceData.floor,
        roomNumber: geofenceData.roomNumber,
        isActive: true,
        createdDate: new Date().toISOString(),
      }

      await collections.geofenceLocations.doc(geofenceId).set(geofenceLocation)
    }

    const sessionId = uuidv4()
    const sessionData = {
      sessionId,
      courseId,
      sessionDate,
      startTime,
      endTime,
      sessionType,
      locationDescription,
      sessionStatus: "SCHEDULED",
      attendanceCount: 0,
      expectedAttendance,
      sessionNotes: sessionNotes || "",
      materials: materials || {},
      createdBy: uid,
      createdDate: new Date().toISOString(),
      modifiedDate: new Date().toISOString(),
      isRecurring: isRecurring || false,
      recurringPattern: recurringPattern || null,
      geofenceId,
    }

    await collections.courseSessions.doc(sessionId).set(sessionData)

    // Notify enrolled students if needed
    // This would be implemented with Firebase Cloud Messaging or another notification service

    res.status(201).json({
      success: true,
      message: "Session created successfully",
      data: { sessionId, ...sessionData },
    })
  } catch (error) {
    next(error)
  }
}

/**
 * Close an attendance session
 * @route PATCH /sessions/:sessionId/close
 */
const closeSession = async (req, res, next) => {
  try {
    const { sessionId } = req.params
    const { uid } = req.user

    // Check if session exists
    const sessionDoc = await collections.courseSessions.doc(sessionId).get()
    if (!sessionDoc.exists) {
      throw new ApiError(404, "Session not found")
    }

    const sessionData = sessionDoc.data()

    // Check if session is already closed
    if (sessionData.sessionStatus === "CLOSED" || sessionData.sessionStatus === "COMPLETED") {
      throw new ApiError(400, "Session is already closed")
    }

    // Check if user is the creator of the session or the course lecturer
    if (sessionData.createdBy !== uid) {
      const courseDoc = await collections.courses.doc(sessionData.courseId).get()
      if (!courseDoc.exists || courseDoc.data().lecturerId !== uid) {
        throw new ApiError(403, "You do not have permission to close this session")
      }
    }

    // Update session status
    await collections.courseSessions.doc(sessionId).update({
      sessionStatus: "CLOSED",
      actualEndTime: new Date().toISOString(),
      modifiedDate: new Date().toISOString(),
    })

    res.status(200).json({
      success: true,
      message: "Session closed successfully",
    })
  } catch (error) {
    next(error)
  }
}

/**
 * Get sessions for a course
 * @route GET /courses/:courseId/sessions
 */
const getCourseSessions = async (req, res, next) => {
  try {
    const { courseId } = req.params
    const { status, date, startDate, endDate } = req.query

    // Check if course exists
    const courseDoc = await collections.courses.doc(courseId).get()
    if (!courseDoc.exists) {
      throw new ApiError(404, "Course not found")
    }

    // Build query
    let query = collections.courseSessions.where("courseId", "==", courseId)

    // Filter by status if provided
    if (status) {
      query = query.where("sessionStatus", "==", status.toUpperCase())
    }

    // Filter by specific date if provided
    if (date) {
      query = query.where("sessionDate", "==", date)
    }

    // Get sessions
    const sessionsSnapshot = await query.get()

    let sessions = sessionsSnapshot.docs.map((doc) => doc.data())

    // Filter by date range if provided (client-side filtering since Firestore doesn't support multiple range queries)
    if (startDate && endDate) {
      sessions = sessions.filter((session) => {
        return session.sessionDate >= startDate && session.sessionDate <= endDate
      })
    }

    // Sort by date and time
    sessions.sort((a, b) => {
      const dateA = new Date(`${a.sessionDate}T${a.startTime}`)
      const dateB = new Date(`${b.sessionDate}T${b.startTime}`)
      return dateA - dateB
    })

    res.status(200).json({
      success: true,
      data: sessions,
    })
  } catch (error) {
    next(error)
  }
}

/**
 * Delete a session
 * @route DELETE /sessions/:sessionId
 */
const deleteSession = async (req, res, next) => {
  try {
    const { sessionId } = req.params
    const { uid } = req.user

    // Check if session exists
    const sessionDoc = await collections.courseSessions.doc(sessionId).get()
    if (!sessionDoc.exists) {
      throw new ApiError(404, "Session not found")
    }

    const sessionData = sessionDoc.data()

    // Check if user is the creator of the session, the course lecturer, or an admin
    let hasPermission = false

    if (sessionData.createdBy === uid) {
      hasPermission = true
    } else {
      const courseDoc = await collections.courses.doc(sessionData.courseId).get()
      if (courseDoc.exists && courseDoc.data().lecturerId === uid) {
        hasPermission = true
      } else if (req.userRole === "Admin") {
        hasPermission = true
      }
    }

    if (!hasPermission) {
      throw new ApiError(403, "You do not have permission to delete this session")
    }

    // Delete session and related data in a batch
    const batch = collections.db.batch()

    // Delete session
    batch.delete(collections.courseSessions.doc(sessionId))

    // Delete attendance records
    const attendanceSnapshot = await collections.attendanceRecords.where("sessionId", "==", sessionId).get()

    attendanceSnapshot.docs.forEach((doc) => {
      batch.delete(doc.ref)
    })

    // Delete disputes related to the session
    const disputesSnapshot = await collections.disputes.where("sessionId", "==", sessionId).get()

    disputesSnapshot.docs.forEach((doc) => {
      batch.delete(doc.ref)
    })

    await batch.commit()

    res.status(200).json({
      success: true,
      message: "Session and related data deleted successfully",
    })
  } catch (error) {
    next(error)
  }
}

module.exports = {
  createSession,
  closeSession,
  getCourseSessions,
  deleteSession,
}
