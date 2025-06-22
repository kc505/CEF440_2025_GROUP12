const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const userController = require('../controllers/userController');


router.post('/lecturer', userController.createLecturer);
router.get('/lecturer/:uid', userController.getLecturerById);
router.get('/lecturer', userController.getAllLecturers);
router.put('/courses/:courseId/assign-lecturer', userController.assignLecturer);



router.get('/', userController.getUsersByRole);

router.get('/:uid', userController.getUserById);
router.put('/:uid', userController.updateUser);
router.delete('/:uid', userController.deleteUser);

module.exports = router;
