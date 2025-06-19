import 'package:flutter/painting.dart' show Color;

class Student {
  final String id;
  final String username;
  final String password;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String phoneNumber;
  final DateTime registrationDate;
  final String? profileImageURL;
  
  // Student-specific fields
  final String matriculeNumber;
  final String department;
  final String program;
  final int admissionYear;
  
  // Additional fields for app functionality
  final List<String> enrolledCourses;
  final DateTime? updatedAt;
  final bool isActive;
  
  // Academic status fields
  final String academicStatus; // Active, Suspended, Graduated, etc.
  final double? gpa;
  final int totalCredits;

  Student({
    required this.id,
    required this.username,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.phoneNumber,
    required this.registrationDate,
    this.profileImageURL,
    required this.matriculeNumber,
    required this.department,
    required this.program,
    required this.admissionYear,
    this.enrolledCourses = const [],
    this.updatedAt,
    this.isActive = true,
    this.academicStatus = 'Active',
    this.gpa,
    this.totalCredits = 0,
  });

  // Computed properties
  String get fullName => '$firstName $lastName';
  String get name => fullName; // For backward compatibility
  String get displayName => fullName;
  String get initials => '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}';
  
  int get currentYear => DateTime.now().year - admissionYear + 1;
  String get academicLevel {
    switch (currentYear) {
      case 1:
        return 'Freshman';
      case 2:
        return 'Sophomore';
      case 3:
        return 'Junior';
      case 4:
        return 'Senior';
      default:
        return currentYear > 4 ? 'Graduate' : 'Freshman';
    }
  }

  bool get isGraduated => academicStatus.toLowerCase() == 'graduated';
  bool get isSuspended => academicStatus.toLowerCase() == 'suspended';
  bool get isActiveStudent => isActive && academicStatus.toLowerCase() == 'active';

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'Student',
      phoneNumber: json['phoneNumber'] ?? '',
      registrationDate: json['registrationDate'] != null 
          ? DateTime.parse(json['registrationDate']) 
          : DateTime.now(),
      profileImageURL: json['profileImageURL'],
      matriculeNumber: json['matriculeNumber'] ?? '',
      department: json['department'] ?? '',
      program: json['program'] ?? '',
      admissionYear: json['admissionYear'] ?? DateTime.now().year,
      enrolledCourses: (json['enrolledCourses'] as List<dynamic>?)?.cast<String>() ?? [],
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isActive: json['isActive'] ?? true,
      academicStatus: json['academicStatus'] ?? 'Active',
      gpa: json['gpa']?.toDouble(),
      totalCredits: json['totalCredits'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
      'phoneNumber': phoneNumber,
      'registrationDate': registrationDate.toIso8601String(),
      'profileImageURL': profileImageURL,
      'matriculeNumber': matriculeNumber,
      'department': department,
      'program': program,
      'admissionYear': admissionYear,
      'enrolledCourses': enrolledCourses,
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
      'academicStatus': academicStatus,
      'gpa': gpa,
      'totalCredits': totalCredits,
    };
  }

  Student copyWith({
    String? id,
    String? username,
    String? password,
    String? firstName,
    String? lastName,
    String? email,
    String? role,
    String? phoneNumber,
    DateTime? registrationDate,
    String? profileImageURL,
    String? matriculeNumber,
    String? department,
    String? program,
    int? admissionYear,
    List<String>? enrolledCourses,
    DateTime? updatedAt,
    bool? isActive,
    String? academicStatus,
    double? gpa,
    int? totalCredits,
  }) {
    return Student(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      registrationDate: registrationDate ?? this.registrationDate,
      profileImageURL: profileImageURL ?? this.profileImageURL,
      matriculeNumber: matriculeNumber ?? this.matriculeNumber,
      department: department ?? this.department,
      program: program ?? this.program,
      admissionYear: admissionYear ?? this.admissionYear,
      enrolledCourses: enrolledCourses ?? this.enrolledCourses,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      academicStatus: academicStatus ?? this.academicStatus,
      gpa: gpa ?? this.gpa,
      totalCredits: totalCredits ?? this.totalCredits,
    );
  }

  @override
  String toString() {
    return 'Student(id: $id, name: $fullName, matricule: $matriculeNumber, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Student && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Extension for attendance-related functionality
extension StudentAttendance on Student {
  // Mock attendance data - in real app, this would come from attendance records
  int get totalSessions => 20;
  int get attendedSessions => (totalSessions * 0.85).round();
  double get attendanceRate => totalSessions > 0 ? (attendedSessions / totalSessions) * 100 : 0.0;
  int get missedSessions => totalSessions - attendedSessions;
  
  bool get hasGoodAttendance => attendanceRate >= 75.0;
  String get attendanceStatus {
    if (attendanceRate >= 90) return 'Excellent';
    if (attendanceRate >= 80) return 'Good';
    if (attendanceRate >= 75) return 'Satisfactory';
    if (attendanceRate >= 60) return 'Poor';
    return 'Critical';
  }
  
  Color get attendanceColor {
    if (attendanceRate >= 80) return const Color(0xFF4CAF50); // Green
    if (attendanceRate >= 60) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFF44336); // Red
  }
}
