class Course {
  final String id;
  final String code;
  final String name;
  final String status;
  final String title;
  final String description;
  final int credits;
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
  final bool? isActive;
  final String? venue;
  final String? schedule;

  Course({
    required this.id,
    required this.code,
    required this.name,
    required this.status,
    required this.title,
    required this.description,
    required this.credits,
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
    this.isActive,
    this.venue,
    this.schedule,
  });

  // Factory constructor for creating Course from JSON
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? 'Active',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      credits: json['credits'] ?? 0,
      lecturer: json['lecturer'],
      lecturerId: json['lecturerId'],
      lecturerName: json['lecturerName'],
      semester: json['semester'],
      year: json['year'],
      totalStudents: json['totalStudents'],
      enrolledStudents: json['enrolledStudents'] != null 
          ? List<String>.from(json['enrolledStudents']) 
          : null,
      completedSessions: json['completedSessions'],
      totalSessions: json['totalSessions'],
      department: json['department'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      isActive: json['isActive'],
      venue: json['venue'],
      schedule: json['schedule'],
    );
  }

  // Method for converting Course to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'status': status,
      'title': title,
      'description': description,
      'credits': credits,
      'lecturer': lecturer,
      'lecturerId': lecturerId,
      'lecturerName': lecturerName,
      'semester': semester,
      'year': year,
      'totalStudents': totalStudents,
      'enrolledStudents': enrolledStudents,
      'completedSessions': completedSessions,
      'totalSessions': totalSessions,
      'department': department,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
      'venue': venue,
      'schedule': schedule,
    };
  }

  // Copy with method for creating modified copies
  Course copyWith({
    String? id,
    String? code,
    String? name,
    String? status,
    String? title,
    String? description,
    int? credits,
    String? lecturer,
    String? lecturerId,
    String? lecturerName,
    String? semester,
    int? year,
    int? totalStudents,
    List<String>? enrolledStudents,
    int? completedSessions,
    int? totalSessions,
    String? department,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? venue,
    String? schedule,
  }) {
    return Course(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
      credits: credits ?? this.credits,
      lecturer: lecturer ?? this.lecturer,
      lecturerId: lecturerId ?? this.lecturerId,
      lecturerName: lecturerName ?? this.lecturerName,
      semester: semester ?? this.semester,
      year: year ?? this.year,
      totalStudents: totalStudents ?? this.totalStudents,
      enrolledStudents: enrolledStudents ?? this.enrolledStudents,
      completedSessions: completedSessions ?? this.completedSessions,
      totalSessions: totalSessions ?? this.totalSessions,
      department: department ?? this.department,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      venue: venue ?? this.venue,
      schedule: schedule ?? this.schedule,
    );
  }
}
