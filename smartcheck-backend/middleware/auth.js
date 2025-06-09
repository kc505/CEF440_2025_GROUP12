const { admin } = require("../config/firebase")
const { ApiError } = require("../utils/apiError")

/**
 * Middleware to verify Firebase authentication token
 */
const authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      throw new ApiError(401, "Unauthorized: No token provided")
    }

    const token = authHeader.split(" ")[1]

    const decodedToken = await admin.auth().verifyIdToken(token)
    req.user = decodedToken

    next()
  } catch (error) {
    next(new ApiError(401, "Unauthorized: Invalid token"))
  }
}

/**
 * Middleware to check if user has required role
 * @param {Array} roles - Array of allowed roles
 */
const authorize = (roles) => {
  return async (req, res, next) => {
    try {
      if (!req.user) {
        throw new ApiError(401, "Unauthorized: User not authenticated")
      }

      const { uid } = req.user
      const userDoc = await admin.firestore().collection("users").doc(uid).get()

      if (!userDoc.exists) {
        throw new ApiError(404, "User not found")
      }

      const userData = userDoc.data()

      if (!roles.includes(userData.role)) {
        throw new ApiError(403, "Forbidden: Insufficient permissions")
      }

      req.userRole = userData.role
      next()
    } catch (error) {
      next(error)
    }
  }
}

module.exports = {
  authenticate,
  authorize,
}
