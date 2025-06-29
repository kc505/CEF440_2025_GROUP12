require('dotenv').config();
const express = require('express');
const cors = require('cors');

require('./config/firebase');

const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const courseRoutes = require('./routes/course.routes');
const faceRoutes = require('./routes/faceRoutes');
const attendanceRoutes = require('./routes/attendance.routes');
const disputeRoutes = require('./routes/dispute.routes');
const reportRoutes = require('./routes/report.routes');

const app = express();

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

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/face', faceRoutes);
app.use('/api/courses', courseRoutes);
app.use('/api/attendance', attendanceRoutes);
app.use('/api/disputes', disputeRoutes);
app.use('/api/reports', reportRoutes);

app.get('/', (req, res) => {
  res.status(200).json({ message: "Welcome to the SmartCheck Backend" });
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.statusCode || 500).json({
    status: 'error',
    message: err.message || 'Something broke!'
  });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`SmartCheck backend running on port ${PORT}`));

module.exports = app;