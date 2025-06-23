import 'package:flutter/foundation.dart';

class Geofence {
  final double lat;
  final double lng;

  Geofence({required this.lat, required this.lng});

  factory Geofence.fromJson(Map<String, dynamic> json) {
    return Geofence(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'lat': lat,
    'lng': lng,
  };
}

class Schedule {
  final String dayOfWeek;
  final String time;

  Schedule({required this.dayOfWeek, required this.time});

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      dayOfWeek: json['dayOfWeek'] ?? '',
      time: json['time'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'dayOfWeek': dayOfWeek,
    'time': time,
  };
}

class Course {
  final String id;
  final String code;
  final String name;
  final int credits;
  final Geofence? geofence;
  final Schedule? schedule;

  // Optional for internal use/display
  final String? status;
  final String? title;
  final String? description;
  final String? lecturer;
  final String? lecturerId;
  final String? lecturerName;
  final String? semester;
  final int? year;
  final int? totalStudents;
  final List<String>? enrolledStudents;
  final int? completedSessions;
  final int? totalSessions;
  final String? department;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final String? venue;

  Course({
    required this.id,
    required this.code,
    required this.name,
    required this.credits,
    this.geofence,
    this.schedule,
    this.status,
    this.title,
    this.description,
    this.lecturer,
    this.lecturerId,
    this.lecturerName,
    this.semester,
    this.year,
    this.totalStudents,
    this.enrolledStudents,
    this.completedSessions,
    this.totalSessions,
    this.department,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.venue,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    try {
      return Course(
        id: json['id']?.toString() ?? '',
        code: json['courseCode'] ?? '',
        name: json['courseName'] ?? '',
        credits: json['credits'] ?? 0,
        geofence: json['geofence'] != null ? Geofence.fromJson(json['geofence']) : null,
        schedule: json['schedule'] != null ? Schedule.fromJson(json['schedule']) : null,
        status: json['status'],
        title: json['title'],
        description: json['description'],
        lecturer: json['lecturerId'],
        lecturerId: json['lecturerId'],
        lecturerName: json['lecturerName'],
        semester: json['semester'],
        year: json['year'],
        totalStudents: json['totalStudents'],
        enrolledStudents: json['enrolledStudents'] != null
            ? List<String>.from(json['enrolledStudents'].map((e) => e.toString()))
            : null,
        completedSessions: json['completedSessions'],
        totalSessions: json['totalSessions'],
        department: json['department'],
        createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
        isActive: json['isActive'] ?? true,
        venue: json['venue'],
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing Course: $e\n$stackTrace\n$json');
      return Course(
        id: 'error',
        code: 'ERROR',
        name: 'Error Course',
        credits: 0,
        isActive: false,
      );
    }
  }

  /// ✅ This is the important part: Matches what backend expects!
  Map<String, dynamic> toJson() {
    return {
      'courseCode': code,
      'courseName': name,
      'credits': credits,
      'geofence': geofence?.toJson(),
      'schedule': schedule?.toJson(),
    };
  }
}
