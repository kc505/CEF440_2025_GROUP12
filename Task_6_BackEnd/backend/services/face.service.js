const faceapi = require('face-api.js');
const canvas = require('canvas');
const path = require('path');

const { Canvas, Image, ImageData } = canvas;
faceapi.env.monkeyPatch({ Canvas, Image, ImageData });

// Load models once
const MODEL_PATH = path.join(__dirname, '..', 'models');

let modelsLoaded = false;

const loadModels = async () => {
  if (modelsLoaded) return;
  await faceapi.nets.ssdMobilenetv1.loadFromDisk(MODEL_PATH);
  await faceapi.nets.faceLandmark68Net.loadFromDisk(MODEL_PATH);
  await faceapi.nets.faceRecognitionNet.loadFromDisk(MODEL_PATH);
  modelsLoaded = true;
};

exports.verifyFace = async (imageBase64, storedEmbedding) => {
  try {
    await loadModels();

    const buffer = Buffer.from(imageBase64, 'base64');
    const img = await canvas.loadImage(buffer);

    const detection = await faceapi
      .detectSingleFace(img)
      .withFaceLandmarks()
      .withFaceDescriptor();

    if (!detection) {
      return { match: false, score: null, reason: 'No face detected' };
    }

    const descriptor = detection.descriptor;
    const distance = faceapi.euclideanDistance(descriptor, storedEmbedding);
    const match = distance < 0.5; // You can adjust the threshold

    return {
      match,
      score: distance,
      descriptor
    };
  } catch (error) {
    console.error('Face verification error:', error);
    return { match: false, score: null, error: error.message };
  }
};
