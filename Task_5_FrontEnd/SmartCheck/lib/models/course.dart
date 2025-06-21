class Geofence {
  final double lat;
  // You can add lon or other fields here if needed

  Geofence({required this.lat});

  factory Geofence.fromJson(Map<String, dynamic> json) {
    return Geofence(
      lat: (json['lat'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
    };
  }
}

class Schedule {
  final String dayOfWeek;

  Schedule({required this.dayOfWeek});

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      dayOfWeek: json['dayOfWeek'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
    };
  }
}

class Course {
  final String? id;  // Firestore doc ID
  final String courseCode;
  final String courseName;
  final DateTime? createdDate;
  final int credits;
  final Geofence? geofence;
  final bool isActive;
  final String? lecturerId;
  final Schedule? schedule;

  Course({
    this.id,
    required this.courseCode,
    required this.courseName,
    this.createdDate,
    required this.credits,
    this.geofence,
    required this.isActive,
    this.lecturerId,
    this.schedule,
  });

  factory Course.fromJson(Map<String, dynamic> json, {String? id}) {
    return Course(
      id: id,
      courseCode: json['courseCode'] ?? '',
      courseName: json['courseName'] ?? '',
      createdDate: json['createdDate'] != null
          ? DateTime.parse(json['createdDate'])
          : null,
      credits: (json['credits'] ?? 0).toInt(),
      geofence: json['geofence'] != null ? Geofence.fromJson(json['geofence']) : null,
      isActive: json['isActive'] ?? false,
      lecturerId: json['lecturerId'],
      schedule: json['schedule'] != null ? Schedule.fromJson(json['schedule']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseCode': courseCode,
      'courseName': courseName,
      'createdDate': createdDate?.toIso8601String(),
      'credits': credits,
      'geofence': geofence?.toJson(),
      'isActive': isActive,
      'lecturerId': lecturerId,
      'schedule': schedule?.toJson(),
    };
  }
}
