

require('dotenv').config(); 
const express = require('express');
const cors = require('cors');

require('./config/firebase'); 

// ADDED: Import your route files
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');


const app = express();
app.use(cors());


app.use(express.json());
app.use(express.urlencoded({ extended: true })); 


app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);

app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.statusCode || 500).json({ 
    status: 'error',
    message: err.message || 'Something broke!' 
  });
});

const PORT = process.env.PORT
app.listen(PORT, async () => {
  console.log(`SmartCheck backend running on port ${PORT}`);
  
});
