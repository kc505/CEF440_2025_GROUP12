/**
 * Custom API Error class
 */
class ApiError extends Error {
  constructor(statusCode, message, errors = []) {
    super(message)
    this.statusCode = statusCode
    this.errors = errors
    this.name = this.constructor.name
    Error.captureStackTrace(this, this.constructor)
  }
}

module.exports = {
  ApiError,
}
