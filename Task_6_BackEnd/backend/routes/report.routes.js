const express = require('express');
const router = express.Router();
const controller = require('../controllers/report.controller');

router.get('/summary/:courseId', controller.attendanceSummary);
router.get('/student/:studentId', controller.studentHistory);

module.exports = router;
