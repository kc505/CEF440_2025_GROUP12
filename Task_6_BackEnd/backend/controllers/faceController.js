const { faceapi, canvas } = require("../config/faceApiConfig");
const { db } = require('../config/firebase');

const imageFromBuffer = async (buffer) => {
  const img = await canvas.loadImage(buffer);
  return faceapi.createCanvasFromMedia(img);
};

const computeDescriptor = async (buffer) => {
  const imgCanvas = await imageFromBuffer(buffer);
  const detection = await faceapi.detectSingleFace(imgCanvas).withFaceLandmarks().withFaceDescriptor();
  if (!detection) throw new Error("No face detected");
  return detection.descriptor;
};

exports.registerFace = async (req, res) => {
  try {
    const { studentId, isActive, imageBase64 } = req.body;

    if (!studentId) {
      return res.status(400).json({ error: "studentId is required" });
    }
    if (!imageBase64) {
      return res.status(400).json({ error: "Image data (imageBase64) is required" });
    }

    // Remove any data URL prefix if present (e.g., "data:image/jpeg;base64,")
    const base64Data = imageBase64.replace(/^data:image\/\w+;base64,/, "");
    // Convert base64 string to Buffer
    const buffer = Buffer.from(base64Data, 'base64');

    // Compute the face descriptor from the buffer
    const descriptor = await computeDescriptor(buffer);

    // Save user data with facial embedding
    await db.collection("users").doc(studentId).set({
      facialEmbedding: Array.from(descriptor),
      isActive: isActive || "true",
      studentId,
    });

    return res.status(201).json({ message: "Face registered successfully" });
  } catch (err) {
    console.error("Register face error:", err);
    return res.status(400).json({ error: err.message });
  }
};

exports.verifyFace = async (req, res) => {
  try {
    const { studentId } = req.body;
    const descriptor = await computeDescriptor(req.file.buffer);

    const userDoc = await db.collection("users").doc(studentId).get();
    if (!userDoc.exists) throw new Error("User not found");

    const storedDescriptor = Float32Array.from(userDoc.data().facialEmbedding);

    const distance = faceapi.euclideanDistance(descriptor, storedDescriptor);
    const isMatch = distance < 0.6; // Adjust threshold based on testing

    return res.status(200).json({ match: isMatch, distance });
  } catch (err) {
    return res.status(400).json({ error: err.message });
  }
};
