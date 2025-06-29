const faceapi = require('@vladmandic/face-api');
const canvas = require('canvas');

(async () => {
  // Load models (adjust path if needed)
  await faceapi.nets.ssdMobilenetv1.loadFromDisk('./models');
  console.log('✅ Models loaded successfully!');
})().catch(err => console.error('❌ Error:', err));