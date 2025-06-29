const axios = require("axios");
const dotenv = require("dotenv");

dotenv.config()

/**
 * Reverse geocode coordinates to get human-readable address
 * @param {number} latitude
 * @param {number} longitude
 * @returns {Promise<string>} Address string
 */
async function reverseGeocode(latitude, longitude) {
  try {
    // Using a free geocoding service (you can replace with your preferred service)
    const response = await axios.get(
      `https://api.opencagedata.com/geocode/v1/json?q=${latitude}+${longitude}&key=${process.env.OPENCAGE_API_KEY}`,
    )

    if (response.data.results && response.data.results.length > 0) {
      return response.data.results[0].formatted
    }

    // Fallback to coordinate string
    return `${latitude.toFixed(6)}, ${longitude.toFixed(6)}`
  } catch (error) {
    console.error("Reverse geocoding error:", error.message)
    return `${latitude.toFixed(6)}, ${longitude.toFixed(6)}`
  }
}

/**
 * Calculate distance between two points using Haversine formula
 * @param {number} lat1
 * @param {number} lon1
 * @param {number} lat2
 * @param {number} lon2
 * @returns {number} Distance in meters
 */
function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371e3 // Earth's radius in metres
  const φ1 = (lat1 * Math.PI) / 180
  const φ2 = (lat2 * Math.PI) / 180
  const Δφ = ((lat2 - lat1) * Math.PI) / 180
  const Δλ = ((lon2 - lon1) * Math.PI) / 180

  const a = Math.sin(Δφ / 2) * Math.sin(Δφ / 2) + Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ / 2) * Math.sin(Δλ / 2)
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

  return R * c
}

/**
 * Check if a point is within a geofence
 * @param {number} pointLat
 * @param {number} pointLon
 * @param {number} centerLat
 * @param {number} centerLon
 * @param {number} radius - Radius in meters
 * @returns {boolean}
 */
function isWithinGeofence(pointLat, pointLon, centerLat, centerLon, radius) {
  const distance = calculateDistance(pointLat, pointLon, centerLat, centerLon)
  return distance <= radius
}

module.exports = {
  reverseGeocode,
  calculateDistance,
  isWithinGeofence,
}
