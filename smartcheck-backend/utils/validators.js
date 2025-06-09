const { body, param, query, validationResult } = require("express-validator")
const { ApiError } = require("./apiError")

/**
 * Validate request data
 */
const validate = (req, res, next) => {
  const errors = validationResult(req)
  if (!errors.isEmpty()) {
    throw new ApiError(400, "Validation Error", errors.array())
  }
  next()
}

/**
 * Course validation rules
 */
const courseValidationRules = {
  create: [
    body("courseCode").notEmpty().withMessage("Course code is required"),
    body("courseName").notEmpty().withMessage("Course name is required"),
    body("credits").isInt({ min: 1, max: 6 }).withMessage("Credits must be between 1 and 6"),
    body("semester").isInt({ min: 1, max: 8 }).withMessage("Semester must be between 1 and 8"),
    body("academicYear").notEmpty().withMessage("Academic year is required"),
    body("maxStudents").isInt({ min: 1, max: 500 }).withMessage("Max students must be between 1 and 500"),
    body("courseType")
      .isIn(["LECTURE", "LAB", "HYBRID", "ONLINE", "TUTORIAL", "SEMINAR", "EXAM"])
      .withMessage("Invalid course type"),
    body("schedule").isObject().withMessage("Schedule must be an object"),
    validate,
  ],
  enroll: [
    param("courseId").isUUID().withMessage("Invalid course ID"),
    body("studentId").notEmpty().withMessage("Student ID is required"),
    validate,
  ],
  get: [param("courseId").isUUID().withMessage("Invalid course ID"), validate],
  getUserCourses: [param("uid").notEmpty().withMessage("User ID is required"), validate],
  delete: [param("courseId").isUUID().withMessage("Invalid course ID"), validate],
}

/**
 * Session validation rules
 */
const sessionValidationRules = {
  create: [
    body("courseId").isUUID().withMessage("Course ID is required"),
    body("sessionDate").isDate().withMessage("Valid session date is required"),
    body("startTime").notEmpty().withMessage("Start time is required"),
    body("endTime").notEmpty().withMessage("End time is required"),
    body("sessionType")
      .isIn(["LECTURE", "LAB", "TUTORIAL", "SEMINAR", "EXAM", "ONLINE"])
      .withMessage("Invalid session type"),
    body("locationDescription").notEmpty().withMessage("Location description is required"),
    body("expectedAttendance").isInt({ min: 1 }).withMessage("Expected attendance must be a positive integer"),
    validate,
  ],
  close: [param("sessionId").isUUID().withMessage("Invalid session ID"), validate],
  getCourseSessions: [param("courseId").isUUID().withMessage("Invalid course ID"), validate],
  delete: [param("sessionId").isUUID().withMessage("Invalid session ID"), validate],
}

module.exports = {
  validate,
  courseValidationRules,
  sessionValidationRules,
}
