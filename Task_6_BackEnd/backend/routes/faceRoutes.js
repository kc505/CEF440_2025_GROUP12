const express = require('express');
const router = express.Router();
const { verifyFace } = require('../services/face.service.js');

router.post('/verify', async (req, res) => {
  const { imageBase64, storedEmbedding } = req.body;

  if (!imageBase64 || !storedEmbedding) {
    return res.status(400).json({ error: 'Missing parameters' });
  }

  try {
    const result = await verifyFace(imageBase64, storedEmbedding);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: 'Error verifying face', details: err.message });
  }
});

module.exports = router;
