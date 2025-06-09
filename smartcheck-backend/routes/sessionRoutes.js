const express = require("express")
const { authenticate, authorize } = require("../middleware/auth")
const { sessionValidationRules } = require("../utils/validators")
const { createSession, closeSession, getCourseSessions, deleteSession } = require("../controllers/sessionController")

const router = express.Router()

// Create a new attendance session
router.post("/", authenticate, authorize(["Lecturer", "Admin"]), sessionValidationRules.create, createSession)

// Close an attendance session
router.patch(
  "/:sessionId/close",
  authenticate,
  authorize(["Lecturer", "Admin"]),
  sessionValidationRules.close,
  closeSession,
)

// Get sessions for a course
router.get("/course/:courseId", authenticate, sessionValidationRules.getCourseSessions, getCourseSessions)

// Delete a session
router.delete(
  "/:sessionId",
  authenticate,
  authorize(["Lecturer", "Admin"]),
  sessionValidationRules.delete,
  deleteSession,
)

module.exports = router
