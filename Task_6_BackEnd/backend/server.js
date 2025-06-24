require('dotenv').config();
const express = require('express');
const cors = require('cors');

require('./config/firebase');

const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const courseRoutes = require('./routes/course.routes');
const faceRoutes = require('./routes/faceRoutes'); // KEEP THIS, but updated to call Python

const app = express();
const PORT = process.env.PORT || 5000;

// CORS settings
const allowedOrigins = [
  'http://localhost:3000',
  'https://your-production-frontend.com',
];

app.use(cors({
  origin: (origin, callback) => {
    if (!origin || allowedOrigins.includes(origin) || origin.startsWith('http://localhost:')) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  }
}));

app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/face', faceRoutes); // Points to routes that will proxy to Python
app.use('/api/courses', courseRoutes);

app.get("/", (req, res) => res.send("SmartCheck backend running"));

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.statusCode || 500).json({
    status: 'error',
    message: err.message || 'Something broke!'
  });
});

// START SERVER
app.listen(PORT, () => {
  console.log(`SmartCheck backend running on port ${PORT}`);
});
