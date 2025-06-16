const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const authMiddleware = require('../middleware/authMiddleware'); // All user routes should be protected

// Apply auth middleware to all routes in this file
router.use(authMiddleware);

// GET /users/:uid
router.get('/:uid', userController.getUserById);

// PATCH /users/:uid
router.patch('/:uid', userController.updateUser);

// DELETE /users/:uid (Admin only - authorization handled in controller)
router.delete('/:uid', userController.deleteUser);

// GET /users?role=student (or other roles)
router.get('/', userController.getUsersByRole); // e.g. /users?role=STUDENT

module.exports = router;