const express = require('express');
const router = express.Router();
const courseController = require('../controllers/course.controller');

router.post('/', courseController.createCourse);
router.get('/', courseController.getAllCourses);
router.get('/:courseId', courseController.getCourseById);
router.put('/:courseId', courseController.updateCourse);
router.delete('/:courseId', courseController.deleteCourse);

// 👨‍🏫 Assign Lecturer
router.patch('/:courseId/assign-lecturer', courseController.assignLecturer);

module.exports = router;
