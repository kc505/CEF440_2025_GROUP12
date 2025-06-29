const { DataTypes } = require("sequelize")
const sequelize = require("../config/firebase")

const AttendanceRecord = sequelize.define(
  "AttendanceRecord",
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    sessionId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: "sessions",
        key: "id",
      },
    },
    studentId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: "Users",
        key: "id",
      },
    },
    status: {
      type: DataTypes.ENUM("Present", "Absent"),
      allowNull: false,
      defaultValue: "Absent",
    },
    checkInTime: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    // Geolocation data when student checked in
    checkInLatitude: {
      type: DataTypes.DECIMAL(10, 8),
      allowNull: true,
    },
    checkInLongitude: {
      type: DataTypes.DECIMAL(11, 8),
      allowNull: true,
    },
    distanceFromGeofence: {
      type: DataTypes.DECIMAL(8, 2), // Distance in meters
      allowNull: true,
    },
    // Face recognition data
    faceRecognitionScore: {
      type: DataTypes.DECIMAL(5, 4), // Confidence score 0-1
      allowNull: true,
    },
    faceImageUrl: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    // Manual override fields (for lecturer corrections)
    isManualOverride: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    overrideBy: {
      type: DataTypes.UUID,
      allowNull: true,
      references: {
        model: "Users",
        key: "id",
      },
    },
    overrideAt: {
      type: DataTypes.DATE,
      allowNull: true,
    },
  },
  {
    timestamps: true,
    tableName: "attendance_records",
    indexes: [
      {
        fields: ["sessionId"],
      },
      {
        fields: ["studentId"],
      },
      {
        fields: ["status"],
      },
      {
        fields: ["checkInTime"],
      },
      {
        unique: true,
        fields: ["sessionId", "studentId"],
      },
    ],
  },
)

// Instance methods
AttendanceRecord.prototype.markPresent = function (
  latitude,
  longitude,
  distance,
  faceScore = null,
  faceImageUrl = null,
) {
  this.status = "Present"
  this.checkInTime = new Date()
  this.checkInLatitude = latitude
  this.checkInLongitude = longitude
  this.distanceFromGeofence = distance
  this.faceRecognitionScore = faceScore
  this.faceImageUrl = faceImageUrl
  return this.save()
}

AttendanceRecord.prototype.manualOverride = function (newStatus, overrideByUserId) {
  this.status = newStatus
  this.isManualOverride = true
  this.overrideBy = overrideByUserId
  this.overrideAt = new Date()
  return this.save()
}

module.exports = AttendanceRecord
