const admin = require("firebase-admin")

// Initialize Firebase Admin (you'll need to set up Firebase)
// admin.initializeApp({
//   credential: admin.credential.cert(serviceAccount),
//   // other config
// });

/**
 * Send push notifications to students
 * @param {Array} students - Array of student objects
 * @param {Object} notification - Notification data
 */
async function notifyStudents(students, notification) {
  try {
    // Filter students who have FCM tokens
    const studentsWithTokens = students.filter((student) => student.fcmToken)

    if (studentsWithTokens.length === 0) {
      console.log("No students with FCM tokens found")
      return
    }

    const tokens = studentsWithTokens.map((student) => student.fcmToken)

    const message = {
      notification: {
        title: notification.title,
        body: notification.message,
      },
      data: {
        type: notification.type,
        sessionId: notification.sessionId,
        courseId: notification.courseId,
      },
      tokens: tokens,
    }

    // Send multicast message
    const response = await admin.messaging().sendMulticast(message)

    console.log(`Successfully sent ${response.successCount} notifications out of ${tokens.length}`)

    if (response.failureCount > 0) {
      console.log(`Failed to send ${response.failureCount} notifications`)
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          console.error(`Failed to send to token ${tokens[idx]}: ${resp.error}`)
        }
      })
    }

    return response
  } catch (error) {
    console.error("Error sending notifications:", error)
    throw error
  }
}

/**
 * Send email notifications (fallback)
 * @param {Array} students
 * @param {Object} notification
 */
async function sendEmailNotifications(students, notification) {
  // Implement email sending logic here
  // You can use services like SendGrid, AWS SES, etc.
  console.log(`Sending email notifications to ${students.length} students`)
}

module.exports = {
  notifyStudents,
  sendEmailNotifications,
}
