const express = require("express")
const { authenticate, authorize } = require("../middleware/auth")
const { courseValidationRules } = require("../utils/validators")
const {
  createCourse,
  enrollInCourse,
  getCourse,
  getUserCourses,
  deleteCourse,
} = require("../controllers/courseController")

const router = express.Router()

// Create a new course
router.post("/", authenticate, authorize(["Lecturer", "Admin"]), courseValidationRules.create, createCourse)

// Enroll a student in a course
router.post(
  "/:courseId/enroll",
  authenticate,
  authorize(["Student", "Lecturer", "Admin"]),
  courseValidationRules.enroll,
  enrollInCourse,
)

// Get course details
router.get("/:courseId", authenticate, courseValidationRules.get, getCourse)

// Get courses for a specific user
router.get("/user/:uid", authenticate, courseValidationRules.getUserCourses, getUserCourses)

// Delete a course
router.delete("/:courseId", authenticate, authorize(["Lecturer", "Admin"]), courseValidationRules.delete, deleteCourse)

module.exports = router
