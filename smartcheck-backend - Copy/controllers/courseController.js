const { v4: uuidv4 } = require("uuid")
const { collections } = require("../config/firebase")
const { ApiError } = require("../utils/apiError")

/**
 * Create a new course
 * @route POST /courses
 */
const createCourse = async (req, res, next) => {
  try {
    const { uid } = req.user

    // Check if user is a lecturer
    const lecturerDoc = await collections.lecturers.doc(uid).get()
    if (!lecturerDoc.exists) {
      throw new ApiError(403, "Only lecturers can create courses")
    }

    const {
      courseCode,
      courseName,
      courseDescription,
      credits,
      semester,
      academicYear,
      maxStudents,
      courseType,
      prerequisites,
      schedule,
      location,
    } = req.body

    // Check if course code already exists
    const existingCourse = await collections.courses.where("courseCode", "==", courseCode).get()

    if (!existingCourse.empty) {
      throw new ApiError(409, "Course with this code already exists")
    }

    const courseId = uuidv4()
    const courseData = {
      courseId,
      courseCode,
      courseName,
      courseDescription: courseDescription || "",
      credits,
      semester,
      academicYear,
      lecturerId: uid,
      maxStudents,
      currentEnrollment: 0,
      enrollmentStatus: "OPEN",
      courseType,
      prerequisites: prerequisites || {},
      schedule,
      location: location || "",
      createdDate: new Date().toISOString(),
      isActive: true,
    }

    await collections.courses.doc(courseId).set(courseData)

    res.status(201).json({
      success: true,
      message: "Course created successfully",
      data: { courseId, ...courseData },
    })
  } catch (error) {
    next(error)
  }
}

/**
 * Enroll a student in a course
 * @route POST /courses/:courseId/enroll
 */
const enrollInCourse = async (req, res, next) => {
  try {
    const { courseId } = req.params
    const { studentId } = req.body

    // Check if course exists
    const courseDoc = await collections.courses.doc(courseId).get()
    if (!courseDoc.exists) {
      throw new ApiError(404, "Course not found")
    }

    const courseData = courseDoc.data()

    // Check if course is open for enrollment
    if (courseData.enrollmentStatus !== "OPEN") {
      throw new ApiError(400, "Course is not open for enrollment")
    }

    // Check if course is full
    if (courseData.currentEnrollment >= courseData.maxStudents) {
      throw new ApiError(400, "Course is full")
    }

    // Check if student exists
    const studentDoc = await collections.students.doc(studentId).get()
    if (!studentDoc.exists) {
      throw new ApiError(404, "Student not found")
    }

    // Check if student is already enrolled
    const existingEnrollment = await collections.courseEnrollments
      .where("studentId", "==", studentId)
      .where("courseId", "==", courseId)
      .get()

    if (!existingEnrollment.empty) {
      throw new ApiError(409, "Student is already enrolled in this course")
    }

    const enrollmentId = uuidv4()
    const enrollmentData = {
      enrollmentId,
      studentId,
      courseId,
      enrollmentDate: new Date().toISOString(),
      enrollmentStatus: "ACTIVE",
      attendancePercentage: 0.0,
    }

    // Create enrollment and update course enrollment count in a transaction
    const batch = collections.db.batch()

    batch.set(collections.courseEnrollments.doc(enrollmentId), enrollmentData)
    batch.update(collections.courses.doc(courseId), {
      currentEnrollment: courseData.currentEnrollment + 1,
      enrollmentStatus: courseData.currentEnrollment + 1 >= courseData.maxStudents ? "FULL" : "OPEN",
    })

    await batch.commit()

    res.status(201).json({
      success: true,
      message: "Student enrolled successfully",
      data: enrollmentData,
    })
  } catch (error) {
    next(error)
  }
}

/**
 * Get course details
 * @route GET /courses/:courseId
 */
const getCourse = async (req, res, next) => {
  try {
    const { courseId } = req.params

    const courseDoc = await collections.courses.doc(courseId).get()
    if (!courseDoc.exists) {
      throw new ApiError(404, "Course not found")
    }

    const courseData = courseDoc.data()

    // Get lecturer details
    const lecturerDoc = await collections.lecturers.doc(courseData.lecturerId).get()
    const lecturerData = lecturerDoc.exists ? lecturerDoc.data() : null

    // Get enrolled students
    const enrollmentsSnapshot = await collections.courseEnrollments
      .where("courseId", "==", courseId)
      .where("enrollmentStatus", "==", "ACTIVE")
      .get()

    const enrolledStudents = []

    for (const doc of enrollmentsSnapshot.docs) {
      const enrollment = doc.data()
      const studentDoc = await collections.students.doc(enrollment.studentId).get()

      if (studentDoc.exists) {
        const studentData = studentDoc.data()
        const userDoc = await collections.users.doc(enrollment.studentId).get()
        const userData = userDoc.exists ? userDoc.data() : {}

        enrolledStudents.push({
          studentId: enrollment.studentId,
          name: `${userData.firstName || ""} ${userData.lastName || ""}`,
          enrollmentNumber: studentData.enrollmentNumber,
          enrollmentDate: enrollment.enrollmentDate,
        })
      }
    }

    const response = {
      ...courseData,
      lecturer: lecturerData
        ? {
            id: courseData.lecturerId,
            name: `${lecturerData.firstName || ""} ${lecturerData.lastName || ""}`,
            department: lecturerData.department,
          }
        : null,
      enrolledStudents,
    }

    res.status(200).json({
      success: true,
      data: response,
    })
  } catch (error) {
    next(error)
  }
}

/**
 * Get courses for a specific user
 * @route GET /users/:uid/courses
 */
const getUserCourses = async (req, res, next) => {
  try {
    const { uid } = req.params

    // Check if user exists
    const userDoc = await collections.users.doc(uid).get()
    if (!userDoc.exists) {
      throw new ApiError(404, "User not found")
    }

    const userData = userDoc.data()
    const { role } = userData

    let courses = []

    if (role === "Student") {
      // Get courses where student is enrolled
      const enrollmentsSnapshot = await collections.courseEnrollments
        .where("studentId", "==", uid)
        .where("enrollmentStatus", "==", "ACTIVE")
        .get()

      const courseIds = enrollmentsSnapshot.docs.map((doc) => doc.data().courseId)

      for (const courseId of courseIds) {
        const courseDoc = await collections.courses.doc(courseId).get()
        if (courseDoc.exists) {
          courses.push({
            ...courseDoc.data(),
            enrollmentDate: enrollmentsSnapshot.docs.find((doc) => doc.data().courseId === courseId).data()
              .enrollmentDate,
          })
        }
      }
    } else if (role === "Lecturer") {
      // Get courses where user is the lecturer
      const coursesSnapshot = await collections.courses
        .where("lecturerId", "==", uid)
        .where("isActive", "==", true)
        .get()

      courses = coursesSnapshot.docs.map((doc) => doc.data())
    }

    res.status(200).json({
      success: true,
      data: courses,
    })
  } catch (error) {
    next(error)
  }
}

/**
 * Delete a course
 * @route DELETE /courses/:courseId
 */
const deleteCourse = async (req, res, next) => {
  try {
    const { courseId } = req.params
    const { uid } = req.user

    // Check if course exists
    const courseDoc = await collections.courses.doc(courseId).get()
    if (!courseDoc.exists) {
      throw new ApiError(404, "Course not found")
    }

    const courseData = courseDoc.data()

    // Check if user is the lecturer of the course or an admin
    if (courseData.lecturerId !== uid && req.userRole !== "Admin") {
      throw new ApiError(403, "You do not have permission to delete this course")
    }

    // Delete course and related data in a batch
    const batch = collections.db.batch()

    // Delete course
    batch.delete(collections.courses.doc(courseId))

    // Delete enrollments
    const enrollmentsSnapshot = await collections.courseEnrollments.where("courseId", "==", courseId).get()

    enrollmentsSnapshot.docs.forEach((doc) => {
      batch.delete(doc.ref)
    })

    // Delete sessions
    const sessionsSnapshot = await collections.courseSessions.where("courseId", "==", courseId).get()

    sessionsSnapshot.docs.forEach((doc) => {
      batch.delete(doc.ref)
    })

    // Delete class schedules
    const schedulesSnapshot = await collections.classSchedules.where("courseId", "==", courseId).get()

    schedulesSnapshot.docs.forEach((doc) => {
      batch.delete(doc.ref)
    })

    await batch.commit()

    res.status(200).json({
      success: true,
      message: "Course and related data deleted successfully",
    })
  } catch (error) {
    next(error)
  }
}

module.exports = {
  createCourse,
  enrollInCourse,
  getCourse,
  getUserCourses,
  deleteCourse,
}
