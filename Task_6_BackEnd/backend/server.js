

require('dotenv').config(); 
const express = require('express');
const cors = require('cors');

require('./config/firebase');
const { loadModels } = require("./config/faceApiConfig");

// ADDED: Import your route files
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const courseRoutes = require('./routes/course.routes');
const faceRoutes = require("./routes/faceRoutes");


const app = express();
app.use(cors());
app.use(express.json());


const attendanceRoutes = require('./routes/attendance.routes');
const disputeRoutes = require('./routes/dispute.routes');
const reportRoutes = require('./routes/report.routes');

app.use('/api/attendance', attendanceRoutes);
app.use('/api/disputes', disputeRoutes);
app.use('/api/reports', reportRoutes);

app.get('/', (req, res) => {
  res.status(200).json({ message: "Welcome to the SmartCheck Backend" });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`SmartCheck backend running on port ${PORT}`));

module.exports = app;
