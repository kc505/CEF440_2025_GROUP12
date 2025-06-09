const admin = require("firebase-admin")
const serviceAccount = require("../serviceAccountKey.json")

// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://smartcheck-attendance-default-rtdb.firebaseio.com",
})

const db = admin.firestore()
const auth = admin.auth()

// Collections
const collections = {
  users: db.collection("users"),
  students: db.collection("students"),
  lecturers: db.collection("lecturers"),
  admins: db.collection("admins"),
  courses: db.collection("courses"),
  courseEnrollments: db.collection("courseEnrollments"),
  courseSessions: db.collection("courseSessions"),
  classSchedules: db.collection("classSchedules"),
  geofenceLocations: db.collection("geofenceLocations"),
  attendanceRecords: db.collection("attendanceRecords"),
  facialData: db.collection("facialData"),
  leaveRequests: db.collection("leaveRequests"),
  disputes: db.collection("disputes"),
}

module.exports = {
  admin,
  db,
  auth,
  collections,
}
