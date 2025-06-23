const tf = require('@tensorflow/tfjs');
const faceapi = require("face-api.js");
const canvas = require("canvas");
const path = require("path");

tf.setBackend('cpu');

const { Canvas, Image, ImageData } = canvas;
faceapi.env.monkeyPatch({ Canvas, Image, ImageData });

const MODELS_PATH = path.join(__dirname, "../models"); // download face-api.js models into this folder

const loadModels = async () => {
  await faceapi.nets.ssdMobilenetv1.loadFromDisk(MODELS_PATH);
  await faceapi.nets.faceLandmark68Net.loadFromDisk(MODELS_PATH);
  await faceapi.nets.faceRecognitionNet.loadFromDisk(MODELS_PATH);
};

module.exports = { faceapi, loadModels, canvas };
