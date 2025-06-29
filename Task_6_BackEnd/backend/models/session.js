const { DataTypes } = require("sequelize")
const sequelize = require("../config/firebased")

const Session = sequelize.define(
  "Session",
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    courseId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: "Courses",
        key: "id",
      },
    },
    lecturerId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: "Users",
        key: "id",
      },
    },
    title: {
      type: DataTypes.STRING,
      allowNull: false,
      validate: {
        notEmpty: true,
        len: [1, 255],
      },
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    scheduledDate: {
      type: DataTypes.DATEONLY,
      allowNull: false,
    },
    startTime: {
      type: DataTypes.TIME,
      allowNull: false,
    },
    endTime: {
      type: DataTypes.TIME,
      allowNull: false,
    },
    duration: {
      type: DataTypes.INTEGER, // Duration in minutes
      allowNull: false,
      validate: {
        min: 1,
        max: 480, // 8 hours max
      },
    },
    status: {
      type: DataTypes.ENUM("scheduled", "active", "completed", "cancelled"),
      defaultValue: "scheduled",
      allowNull: false,
    },
    // Geofence data - automatically captured from lecturer's location
    geofenceLatitude: {
      type: DataTypes.DECIMAL(10, 8),
      allowNull: false,
      validate: {
        min: -90,
        max: 90,
      },
    },
    geofenceLongitude: {
      type: DataTypes.DECIMAL(11, 8),
      allowNull: false,
      validate: {
        min: -180,
        max: 180,
      },
    },
    geofenceRadius: {
      type: DataTypes.INTEGER, // Radius in meters
      allowNull: false,
      defaultValue: 50,
      validate: {
        min: 10,
        max: 500,
      },
    },
    geofenceAddress: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    // Settings
    requiresFaceRecognition: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
    },
    allowLateEntry: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    lateEntryMinutes: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
      validate: {
        min: 0,
        max: 60,
      },
    },
    // Activation timestamp
    activatedAt: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    completedAt: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    // Attendance statistics
    totalStudentsEnrolled: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
    },
    attendanceCount: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
    },
    attendanceRate: {
      type: DataTypes.DECIMAL(5, 2), // Percentage with 2 decimal places
      defaultValue: 0.0,
    },
    // Metadata
    createdBy: {
      type: DataTypes.UUID,
      allowNull: false,
    },
    updatedBy: {
      type: DataTypes.UUID,
      allowNull: true,
    },
  },
  {
    timestamps: true,
    tableName: "sessions",
    indexes: [
      {
        fields: ["courseId"],
      },
      {
        fields: ["lecturerId"],
      },
      {
        fields: ["status"],
      },
      {
        fields: ["scheduledDate"],
      },
      {
        fields: ["geofenceLatitude", "geofenceLongitude"],
      },
    ],
  },
)

// Instance methods
Session.prototype.isActive = function () {
  return this.status === "active"
}

Session.prototype.canTakeAttendance = function () {
  const now = new Date()
  const sessionStart = new Date(`${this.scheduledDate}T${this.startTime}`)
  const sessionEnd = new Date(`${this.scheduledDate}T${this.endTime}`)

  if (this.allowLateEntry) {
    const lateEntryEnd = new Date(sessionStart.getTime() + this.lateEntryMinutes * 60000)
    return this.status === "active" && now >= sessionStart && now <= Math.max(sessionEnd, lateEntryEnd)
  }

  return this.status === "active" && now >= sessionStart && now <= sessionEnd
}

Session.prototype.isWithinGeofence = function (studentLat, studentLng) {
  const R = 6371e3 // Earth's radius in metres
  const φ1 = (this.geofenceLatitude * Math.PI) / 180
  const φ2 = (studentLat * Math.PI) / 180
  const Δφ = ((studentLat - this.geofenceLatitude) * Math.PI) / 180
  const Δλ = ((studentLng - this.geofenceLongitude) * Math.PI) / 180

  const a = Math.sin(Δφ / 2) * Math.sin(Δφ / 2) + Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ / 2) * Math.sin(Δλ / 2)
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

  const distance = R * c // Distance in metres

  return distance <= this.geofenceRadius
}

Session.prototype.updateAttendanceStats = async function () {
  const AttendanceRecord = require("./attendanceRecord")

  const attendanceCount = await AttendanceRecord.count({
    where: {
      sessionId: this.id,
      status: "Present", // Updated to match your enum values
    },
  })

  this.attendanceCount = attendanceCount
  this.attendanceRate = this.totalStudentsEnrolled > 0 ? (attendanceCount / this.totalStudentsEnrolled) * 100 : 0

  await this.save()
}

module.exports = Session
