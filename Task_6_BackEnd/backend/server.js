

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
const PORT = process.env.PORT || 5000;

// REPLACED: Swapped basic cors() with a more secure version for production
const allowedOrigins = [
  'http://localhost:3000',
  'https://your-production-frontend.com',
];


app.use(cors({
  origin: (origin, callback) => {
    if (!origin) {
      // Allow non-browser clients like Postman or curl
      callback(null, true);
    } else if (allowedOrigins.includes(origin) || origin.startsWith('http://localhost:')) {
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
app.use("/api/face", faceRoutes);
app.get("/", (req, res) => res.send("Facial Recognition API Running"));
app.use('/api/courses', courseRoutes);

app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.statusCode || 500).json({ 
    status: 'error',
    message: err.message || 'Something broke!' 
  });
});


// START SERVER WITH MODELS LOADED
app.listen(PORT, async () => {
  await loadModels();
  console.log(`SmartCheck backend running on port ${PORT}`);
});
