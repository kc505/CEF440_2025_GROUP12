const admin = require('firebase-admin');
require('dotenv').config(); // Load environment variables

try {
  const serviceAccount = require(process.env.FIREBASE_SERVICE_ACCOUNT_PATH);

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: process.env.FIREBASE_DATABASE_URL
  });

  console.log('Firebase Admin SDK initialized successfully.');
} catch (error) {
  console.error('Error initializing Firebase Admin SDK:', error.message);
  console.error('Ensure FIREBASE_SERVICE_ACCOUNT_PATH in .env points to your service account key JSON file.');
  process.exit(1); // Exit if Firebase Admin SDK fails to initialize
}

module.exports = admin;