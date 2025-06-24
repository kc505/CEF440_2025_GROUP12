const express = require('express');
const axios = require('axios');
const router = express.Router();

const PYTHON_FACE_API = 'http://localhost:5001'; // Update when deploying

router.post('/register', async (req, res) => {
  try {
    const response = await axios.post(`${PYTHON_FACE_API}/register`, req.body);
    res.json(response.data);
  } catch (error) {
    res.status(error.response?.status || 500).json({ error: error.message });
  }
});

router.post('/verify', async (req, res) => {
  try {
    const response = await axios.post(`${PYTHON_FACE_API}/verify`, req.body);
    res.json(response.data);
  } catch (error) {
    res.status(error.response?.status || 500).json({ error: error.message });
  }
});

module.exports = router;
