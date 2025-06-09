const { ApiError } = require("../utils/apiError")

/**
 * Global error handling middleware
 */
const errorHandler = (err, req, res, next) => {
  console.error("Error:", err)

  if (err instanceof ApiError) {
    return res.status(err.statusCode).json({
      success: false,
      message: err.message,
      errors: err.errors,
    })
  }

  // Firebase errors
  if (err.code && err.code.startsWith("auth/")) {
    return res.status(401).json({
      success: false,
      message: err.message || "Authentication error",
    })
  }

  // Default server error
  return res.status(500).json({
    success: false,
    message: "Internal Server Error",
    error: process.env.NODE_ENV === "development" ? err.message : undefined,
  })
}

module.exports = {
  errorHandler,
}
