// =================================================================
// SECTION 1: IMPORTS & INITIAL SETUP (Top of the file)
// =================================================================

require('dotenv').config(); // MUST be the first line to load .env variables
const express = require('express');
const cors = require('cors');

// ADDED: Initialize Firebase Admin SDK. This must run before any routes use it.
require('./config/firebase-config'); // Ensure the path is correct

// ADDED: Import your route files
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');

const app = express();
const PORT = process.env.PORT || 5000; // MODIFIED: Changed default to 5000 to match your original


// =================================================================
// SECTION 2: MIDDLEWARE & ROUTES (Middle of the file)
// =================================================================

// REPLACED: Swapped basic cors() with a more secure version for production
const allowedOrigins = [
  'http://localhost:3000', // Your local frontend dev server
  'https://your-production-frontend.com' // Your deployed app URL
];
app.use(cors({
  origin: (origin, callback) => {
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  }
}));

// KEPT: These are essential middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true })); // ADDED: Good to have for form data

// ADDED: Mount your API routes. All routes from authRoutes will be prefixed with /api/auth
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);

// KEPT & MODIFIED: Your basic root route for checking if the API is alive
app.get('/', (req, res) => {
  res.status(200).json({ message: "Welcome to the SmartCheck Backend API" });
});


// =================================================================
// SECTION 3: ERROR HANDLING & SERVER START (Bottom of the file)
// =================================================================

// ADDED: A global error handler. This should be after all routes.
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.statusCode || 500).json({ 
    status: 'error',
    message: err.message || 'Something broke!' 
  });
});

// REPLACED: Your app.listen with a version that also tests the DB connection on start
app.listen(PORT, async () => {
  console.log(`SmartCheck backend running on port ${PORT}`);
  
  // Optional but recommended: Test relational DB connection on startup
  try {
    const { pool } = require('./config/db'); // Path to your PostgreSQL config
    await pool.query('SELECT NOW()');
    console.log('Successfully connected to the relational database.');
  } catch (error) {
    console.error('CRITICAL: Failed to connect to the relational database on startup.', error);
  }
});

// REMOVED: module.exports = app; (See explanation below)