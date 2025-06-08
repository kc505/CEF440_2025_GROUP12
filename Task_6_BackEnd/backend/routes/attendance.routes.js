const express = require('express');
const router = express.Router();
const controller = require('../controllers/attendance.controller');

router.post('/', controller.markAttendance);
router.get('/student/:studentId', controller.getAttendanceByStudent);
router.get('/session/:sessionId', controller.getAttendanceBySession);

module.exports = router;
