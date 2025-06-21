const express = require('express');
const router = express.Router();
const faceapi = require('face-api.js');
const canvas = require('canvas');
const path = require('path');
const { Canvas, Image, ImageData } = canvas;

faceapi.env.monkeyPatch({ Canvas, Image, ImageData });

const MODEL_PATH = path.join(__dirname, '..', 'models');

// Load face-api.js models once
let modelsLoaded = false;
const loadModels = async () => {
  if (modelsLoaded) return;
  await faceapi.nets.ssdMobilenetv1.loadFromDisk(MODEL_PATH);
  await faceapi.nets.faceLandmark68Net.loadFromDisk(MODEL_PATH);
  await faceapi.nets.faceRecognitionNet.loadFromDisk(MODEL_PATH);
  modelsLoaded = true;
};

// TEMPORARY in-memory storage → replace with real DB later
const users = [];

// 📌 POST /api/face/register
router.post('/register', async (req, res) => {
  try {
    await loadModels();

    const { name, email, password, role, imageBase64 } = req.body;

    if (!name || !email || !password || !role || !imageBase64) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const buffer = Buffer.from(imageBase64, 'base64');
    const img = await canvas.loadImage(buffer);

    const detection = await faceapi
      .detectSingleFace(img)
      .withFaceLandmarks()
      .withFaceDescriptor();

    if (!detection) {
      return res.status(400).json({ error: 'No face detected in the image' });
    }

    const descriptor = Array.from(detection.descriptor);

    // 📝 Store the user → Replace with DB logic in production
    users.push({
      name,
      email,
      password, // ❗ Ideally hash this with bcrypt before saving (security)
      role,
      faceEmbedding: descriptor,
    });

    return res.status(200).json({ success: true, message: 'User registered with face successfully' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Internal Server Error', details: err.message });
  }
});

module.exports = router;
