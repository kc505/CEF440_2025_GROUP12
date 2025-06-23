const admin = require('firebase-admin');
require('dotenv').config();
const path = require('path');

try {
  if (!admin.apps.length) {
    const serviceAccountPath = path.resolve(__dirname, '..', process.env.FIREBASE_SERVICE_ACCOUNT_PATH);
    const serviceAccount = require(serviceAccountPath);

    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      databaseURL: process.env.FIREBASE_DATABASE_URL
    });

    console.log('Firebase Admin SDK initialized successfully.');
  } else {
    console.log('Firebase Admin SDK already initialized.');
  }
} catch (error) {
  console.error('Error initializing Firebase Admin SDK:', error.message);
  console.error('Ensure FIREBASE_SERVICE_ACCOUNT_PATH in .env points to your service account key JSON file.');
  process.exit(1);
}

// Export both admin and Firestore instance
const db = admin.firestore();

module.exports = { admin, db };
