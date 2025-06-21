const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const userController = require('../controllers/userController');

router.get('/:uid', userController.getUserById);
router.put('/:uid',  userController.updateUser);
router.delete('/:uid',  userController.deleteUser);
router.get('/',  userController.getUsersByRole);
router.post('/lecturer', userController.createLecturer);

module.exports = router;
