/**
 * This file defines the Firestore schema for the SmartCheck application
 * It serves as documentation for the database structure
 */

const usersCollection = {
  userID: "UUID", // Primary key
  username: "string",
  passwordHash: "string",
  firstName: "string",
  lastName: "string",
  email: "string",
  role: "enum(Student, Lecturer, Admin)",
  phoneNumber: "string",
  registrationDate: "timestamp",
  lastLoginDate: "timestamp",
  isActive: "boolean",
  profileImageURL: "string",
  twoFactorEnabled: "boolean",
  accountLockoutCount: "number",
  passwordResetToken: "string",
  tokenExpiryDate: "timestamp",
}

const studentsCollection = {
  studentID: "string", // References userID
  enrollmentNumber: "string",
  department: "string",
  semester: "number",
  yearOfStudy: "number",
  program: "string",
  admissionYear: "number",
  cgpa: "number",
  guardianName: "string",
  guardianPhone: "string",
  emergencyContact: "string",
}

const lecturersCollection = {
  facultyID: "string", // References userID
  department: "string",
  employeeNumber: "string",
  designation: "string",
  specialization: "string",
  officeLocation: "string",
  officeHours: "string",
  qualifications: "string",
  joinDate: "date",
  canCreateCourses: "boolean",
}

const adminsCollection = {
  adminID: "string", // References userID
  accessLevel: "number",
  permissions: "object",
  department: "string",
  canManageUsers: "boolean",
  canViewReports: "boolean",
  canModifySettings: "boolean",
  lastActivityDate: "timestamp",
}

const coursesCollection = {
  courseID: "UUID", // Primary key
  courseCode: "string",
  courseName: "string",
  courseDescription: "string",
  credits: "number",
  semester: "number",
  academicYear: "string",
  lecturerID: "string", // References facultyID
  maxStudents: "number",
  currentEnrollment: "number",
  enrollmentStatus: "enum(OPEN, CLOSED, FULL)",
  courseType: "enum(LECTURE, LAB, HYBRID, ONLINE, TUTORIAL, SEMINAR, EXAM)",
  prerequisites: "object",
  schedule: "object",
  location: "string",
  createdDate: "timestamp",
  isActive: "boolean",
}

const courseEnrollmentsCollection = {
  enrollmentID: "UUID", // Primary key
  studentID: "string", // References studentID
  courseID: "UUID", // References courseID
  enrollmentDate: "timestamp",
  enrollmentStatus: "enum(ACTIVE, INACTIVE, WITHDRAWN, COMPLETED)",
  grade: "string",
  gradePoints: "number",
  attendancePercentage: "number",
  withdrawalDate: "timestamp",
  withdrawalReason: "string",
}

const geofenceLocationsCollection = {
  geofenceID: "UUID", // Primary key
  centerLatitude: "number",
  centerLongitude: "number",
  radiusInMeters: "number",
  altitudeMin: "number",
  altitudeMax: "number",
  locationName: "string",
  building: "string",
  floor: "number",
  roomNumber: "string",
  capacity: "number",
  facilities: "object",
  accessRequirements: "object",
  isActive: "boolean",
  createdDate: "timestamp",
  lastCalibrated: "timestamp",
  accuracyLevel: "enum(HIGH, MEDIUM, LOW)",
}

const classSchedulesCollection = {
  scheduleID: "UUID", // Primary key
  courseID: "UUID", // References courseID
  dayOfWeek: "number",
  startTime: "string",
  endTime: "string",
  geofenceID: "UUID", // References geofenceID
  isRecurring: "boolean",
  effectiveStartDate: "date",
  effectiveEndDate: "date",
  sessionType: "enum(LECTURE, LAB, TUTORIAL, EXAM, SEMINAR, ONLINE)",
  attendanceWindow: "number",
  lateThreshold: "number",
  autoCloseAfter: "number",
  reminderBefore: "number",
  isActive: "boolean",
  createdBy: "string", // References facultyID
  createdDate: "timestamp",
  lastModified: "timestamp",
}

const courseSessionsCollection = {
  sessionID: "UUID", // Primary key
  courseID: "UUID", // References courseID
  sessionDate: "date",
  startTime: "string",
  endTime: "string",
  actualStartTime: "timestamp",
  actualEndTime: "timestamp",
  sessionType: "enum(LECTURE, LAB, TUTORIAL, SEMINAR, EXAM, ONLINE)",
  locationDescription: "string",
  sessionStatus: "enum(SCHEDULED, OPEN, CLOSED, CANCELLED, COMPLETED)",
  attendanceCount: "number",
  expectedAttendance: "number",
  sessionNotes: "string",
  recordingURL: "string",
  materials: "object",
  createdBy: "string", // References facultyID
  createdDate: "timestamp",
  modifiedDate: "timestamp",
  isRecurring: "boolean",
  recurringPattern: "object",
  geofenceID: "UUID", // References geofenceID
}

const attendanceRecordsCollection = {
  attendanceID: "UUID", // Primary key
  studentID: "string", // References studentID
  sessionID: "UUID", // References sessionID
  courseID: "UUID", // References courseID
  checkInTime: "timestamp",
  checkOutTime: "timestamp",
  attendanceStatus: "enum(PRESENT, ABSENT, LATE, EXCUSED, PARTIAL)",
  arrivalStatus: "enum(ON_TIME, LATE, VERY_LATE)",
  lateMinutes: "number",
  verificationMethod: "enum(SELF_CHECKIN, LECTURER_ASSISTED, MANUAL_ENTRY)",
  locationLatitude: "number",
  locationLongitude: "number",
  locationAccuracy: "number",
  distanceFromGeofence: "number",
  faceMatchScore: "number",
  faceMatchAttempts: "number",
  deviceInfo: "object",
  ipAddress: "string",
  userAgent: "string",
  batteryLevel: "number",
  networkType: "string",
  isVerified: "boolean",
  verifiedBy: "string", // References userID
  verificationDate: "timestamp",
  notes: "string",
  photoURL: "string",
  isDisputed: "boolean",
  lastModified: "timestamp",
}

module.exports = {
  usersCollection,
  studentsCollection,
  lecturersCollection,
  adminsCollection,
  coursesCollection,
  courseEnrollmentsCollection,
  geofenceLocationsCollection,
  classSchedulesCollection,
  courseSessionsCollection,
  attendanceRecordsCollection,
}
