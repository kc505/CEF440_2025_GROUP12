class Session {
  final String id;
  final String courseId;
  final String courseName;
  final String courseCode;
  final String lecturerId;
  final String lecturerName;
  final String title;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String venue;
  final SessionStatus status;
  final int attendanceCount;
  final int totalStudents;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> enrolledStudents;
  final Map<String, dynamic>? geofenceData;

  Session({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.lecturerId,
    required this.lecturerName,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.venue,
    required this.status,
    required this.attendanceCount,
    required this.totalStudents,
    required this.createdAt,
    this.updatedAt,
    required this.enrolledStudents,
    this.geofenceData,
  });

  // Computed properties
  bool get isActive => status == SessionStatus.open;
  bool get canTakeAttendance => status == SessionStatus.open;
  String get statusText => status.displayName;
  
  Duration get duration {
    final start = _parseTime(startTime);
    final end = _parseTime(endTime);
    return end.difference(start);
  }

  DateTime _parseTime(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  Session copyWith({
    String? id,
    String? courseId,
    String? courseName,
    String? courseCode,
    String? lecturerId,
    String? lecturerName,
    String? title,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? venue,
    SessionStatus? status,
    int? attendanceCount,
    int? totalStudents,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? enrolledStudents,
    Map<String, dynamic>? geofenceData,
  }) {
    return Session(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      courseCode: courseCode ?? this.courseCode,
      lecturerId: lecturerId ?? this.lecturerId,
      lecturerName: lecturerName ?? this.lecturerName,
      title: title ?? this.title,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      venue: venue ?? this.venue,
      status: status ?? this.status,
      attendanceCount: attendanceCount ?? this.attendanceCount,
      totalStudents: totalStudents ?? this.totalStudents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      enrolledStudents: enrolledStudents ?? this.enrolledStudents,
      geofenceData: geofenceData ?? this.geofenceData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'courseName': courseName,
      'courseCode': courseCode,
      'lecturerId': lecturerId,
      'lecturerName': lecturerName,
      'title': title,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'venue': venue,
      'status': status.name,
      'attendanceCount': attendanceCount,
      'totalStudents': totalStudents,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'enrolledStudents': enrolledStudents,
      'geofenceData': geofenceData,
    };
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'],
      courseId: json['courseId'],
      courseName: json['courseName'],
      courseCode: json['courseCode'],
      lecturerId: json['lecturerId'],
      lecturerName: json['lecturerName'],
      title: json['title'],
      date: DateTime.parse(json['date']),
      startTime: json['startTime'],
      endTime: json['endTime'],
      venue: json['venue'],
      status: SessionStatus.values.firstWhere((e) => e.name == json['status']),
      attendanceCount: json['attendanceCount'],
      totalStudents: json['totalStudents'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      enrolledStudents: List<String>.from(json['enrolledStudents'] ?? []),
      geofenceData: json['geofenceData'],
    );
  }
}

enum SessionStatus {
  draft('Draft'),
  open('Open'),
  ongoing('Ongoing'),
  closed('Closed'),
  cancelled('Cancelled');

  const SessionStatus(this.displayName);
  final String displayName;
}

class StudentAttendance {
  final String studentId;
  final String studentName;
  final String matricule;
  final bool isPresent;
  final String? checkInTime;
  final String? verificationMethod;
  final Map<String, dynamic>? faceData;
  final Map<String, dynamic>? locationData;
  final DateTime? timestamp;

  StudentAttendance({
    required this.studentId,
    required this.studentName,
    required this.matricule,
    required this.isPresent,
    this.checkInTime,
    this.verificationMethod,
    this.faceData,
    this.locationData,
    this.timestamp,
  });

  StudentAttendance copyWith({
    String? studentId,
    String? studentName,
    String? matricule,
    bool? isPresent,
    String? checkInTime,
    String? verificationMethod,
    Map<String, dynamic>? faceData,
    Map<String, dynamic>? locationData,
    DateTime? timestamp,
  }) {
    return StudentAttendance(
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      matricule: matricule ?? this.matricule,
      isPresent: isPresent ?? this.isPresent,
      checkInTime: checkInTime ?? this.checkInTime,
      verificationMethod: verificationMethod ?? this.verificationMethod,
      faceData: faceData ?? this.faceData,
      locationData: locationData ?? this.locationData,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'matricule': matricule,
      'isPresent': isPresent,
      'checkInTime': checkInTime,
      'verificationMethod': verificationMethod,
      'faceData': faceData,
      'locationData': locationData,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  factory StudentAttendance.fromJson(Map<String, dynamic> json) {
    return StudentAttendance(
      studentId: json['studentId'],
      studentName: json['studentName'],
      matricule: json['matricule'],
      isPresent: json['isPresent'],
      checkInTime: json['checkInTime'],
      verificationMethod: json['verificationMethod'],
      faceData: json['faceData'],
      locationData: json['locationData'],
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
    );
  }
}
