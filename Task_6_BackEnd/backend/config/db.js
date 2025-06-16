// firebase-config.js
const admin = require('firebase-admin');
require('dotenv').config();

try {
  // Check if the app is already initialized to prevent errors
  if (!admin.apps.length) {
    // Parse the service account key from the environment variable
    const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_KEY);

    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      databaseURL: process.env.FIREBASE_DATABASE_URL, // Essential for Realtime DB/Auth, good practice to include
    });
  }
  
  console.log('Firebase Admin SDK initialized successfully.');

} catch (error) {
  console.error('Error initializing Firebase Admin SDK:', error.message);
  // Optional: Exit the process if Firebase connection is critical
  process.exit(1); 
}

// Export the initialized services
const db = admin.firestore(); // Cloud Firestore instance
const auth = admin.auth();     // Firebase Auth instance

module.exports = {
  admin,
  db,
  auth,
};