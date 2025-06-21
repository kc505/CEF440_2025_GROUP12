class AttendanceSession {
  final String id;
  final String courseId;
  final String courseName;
  final String courseCode;
  final DateTime sessionDate;
  final DateTime startTime;
  final DateTime endTime;
  final String venueId;
  final String venueName;
  final String lecturerId;
  final String lecturerName;
  final List<dynamic> attendances;
  final DateTime createdAt;
  final double attendancePercentage;

  AttendanceSession({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.sessionDate,
    required this.startTime,
    required this.endTime,
    required this.venueId,
    required this.venueName,
    required this.lecturerId,
    required this.lecturerName,
    required this.attendances,
    required this.createdAt,
    required this.attendancePercentage,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'courseName': courseName,
      'courseCode': courseCode,
      'sessionDate': sessionDate.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'venueId': venueId,
      'venueName': venueName,
      'lecturerId': lecturerId,
      'lecturerName': lecturerName,
      'attendances': attendances,
      'createdAt': createdAt.toIso8601String(),
      'attendancePercentage': attendancePercentage,
    };
  }

  factory AttendanceSession.fromJson(Map<String, dynamic> json) {
    return AttendanceSession(
      id: json['id'],
      courseId: json['courseId'],
      courseName: json['courseName'],
      courseCode: json['courseCode'],
      sessionDate: DateTime.parse(json['sessionDate']),
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      venueId: json['venueId'],
      venueName: json['venueName'],
      lecturerId: json['lecturerId'],
      lecturerName: json['lecturerName'],
      attendances: json['attendances'] ?? [],
      createdAt: DateTime.parse(json['createdAt']),
      attendancePercentage: json['attendancePercentage']?.toDouble() ?? 0.0,
    );
  }
}
