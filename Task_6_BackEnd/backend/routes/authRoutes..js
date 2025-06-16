const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const authMiddleware = require('../middleware/authMiddleware');

// --- Public Routes ---

// POST /auth/signup
// Client sends user details (email, password, name, etc.).
// Backend creates the user in Firebase Auth and corresponding database profiles.
router.post('/signup', authController.signup);


// --- Protected Routes (require a valid Firebase ID token) ---

// GET /auth/me
// This is the primary route for a client to get their own profile after logging in.
// The authMiddleware will verify the token from the Authorization header.
router.get('/me', authMiddleware, authController.getMe);

// POST /auth/logout
// The client signals a logout, and the backend revokes refresh tokens for a hard logout.
router.post('/logout', authMiddleware, authController.logout);

module.exports = router;