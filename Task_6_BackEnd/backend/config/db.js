const admin = require('firebase-admin');

try {
  if (!admin.apps.length) {
    const serviceAccount = require('../firebaseServiceKey.json');

    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      databaseURL: 'https://smartcheck-51999.firebaseio.com',
    });
  }
  
  console.log(' Firebase Admin SDK initialized successfully.');
} catch (error) {
  console.error(' Error initializing Firebase Admin SDK:', error.message);
  process.exit(1);
}

const db = admin.firestore();
const auth = admin.auth();

module.exports = {
  admin,
  db,
  auth,
};
