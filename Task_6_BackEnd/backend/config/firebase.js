require("dotenv").config();

const admin = require("firebase-admin");
const fs = require("fs")
const path = require("path")

const serviceAccountPath = path.resolve(__dirname, process.env.FIREBASE_SERVICE_ACCOUNT);

if (!fs.existsSync(serviceAccountPath)) {
  console.error("Service account file not found at path:", serviceAccountPath);
  process.exit(1);
}

const serviceAccount = require(serviceAccountPath);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

console.log("Firebase Admin SDK initialized successfully.");

module.exports = admin;
