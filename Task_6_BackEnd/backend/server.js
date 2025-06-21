

require('dotenv').config(); 
const express = require('express');
const cors = require('cors');

require('./config/firebase');

// ADDED: Import your route files
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const faceRoutes = require('./routes/faceRoutes');

const app = express();
const PORT = process.env.PORT || 5000;

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


app.use(express.json());
app.use(express.urlencoded({ extended: true })); 


app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/face', faceRoutes);

app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.statusCode || 500).json({ 
    status: 'error',
    message: err.message || 'Something broke!' 
  });
});


app.listen(PORT, async () => {
  console.log(`SmartCheck backend running on port ${PORT}`);
  

});
