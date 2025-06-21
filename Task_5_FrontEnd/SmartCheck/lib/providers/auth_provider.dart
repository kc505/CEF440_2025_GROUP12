import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smartcheck/models/student.dart';

enum UserRole { student, lecturer, admin }

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  UserRole? _userRole;
  Map<String, dynamic>? _userData;
  String? _token;
  Student? _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  UserRole? get userRole => _userRole;
  Map<String, dynamic>? get userData => _userData;
  String? get token => _token;
  Student? get currentUser => _currentUser;

  final String baseUrl = "http://YOUR_LOCAL_IP:5000/api"; // 👈 UPDATE this to your backend URL

  // ===================== SIGNUP =====================
  Future<bool> signup(String name, String email, String password, String role) async {
    try {
      final url = Uri.parse('$baseUrl/face/register');

      // Here, send face data with signup (if you want to include face capture)
      // This example only shows sending without face data yet
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
          // 'imageBase64': yourCapturedImageBase64, 👈 TODO: Add face data here during signup flow
        }),
      );

      if (response.statusCode == 200) {
        _isAuthenticated = true;
        _token = 'sample_token';
        _userData = {'name': name, 'email': email, 'role': role};

        switch (role) {
          case 'student':
            _userRole = UserRole.student;
            break;
          case 'lecturer':
            _userRole = UserRole.lecturer;
            break;
          case 'admin':
            _userRole = UserRole.admin;
            break;
        }

        notifyListeners();
        return true;
      } else {
        print('Signup failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Signup error: $e');
      return false;
    }
  }

  // ===================== EMAIL EXISTS CHECK =====================
  Future<bool> checkEmailExists(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/check-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['exists'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }

  // ===================== LOGIN MOCKUP (to replace with real API) =====================
  Future<bool> loginStudent(String matricule, String email, String password) async {
    try {
      // Replace with API → Simulating delay for now
      await Future.delayed(const Duration(seconds: 2));

      _isAuthenticated = true;
      _userRole = UserRole.student;
      _token = 'student_token_${DateTime.now().millisecondsSinceEpoch}';
      _currentUser = Student(
        id: 'STU001',
        username: 'ash',
        password: password,
        firstName: 'Mekole',
        lastName: 'Ashley',
        email: email,
        role: 'Student',
        phoneNumber: '677030466',
        registrationDate: DateTime.now(),
        profileImageURL: null,
        matriculeNumber: matricule,
        department: 'Computer Engineering',
        program: 'BEng Computer Engineering',
        admissionYear: 2023,
        enrolledCourses: ['CE101', 'MAT101', 'PHY101'],
        academicStatus: 'Active',
        gpa: 3.75,
        totalCredits: 45,
      );

      _userData = {
        'matricule': matricule,
        'email': email,
        'name': _currentUser!.fullName,
        'role': 'student',
      };

      notifyListeners();
      return true;
    } catch (e) {
      print('Student login error: $e');
      return false;
    }
  }

  // Lecturer login → same idea as above, to replace with real API call
  Future<bool> loginLecturer(String facultyNumber, String email, String password) async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      _isAuthenticated = true;
      _userRole = UserRole.lecturer;
      _token = 'lecturer_token_${DateTime.now().millisecondsSinceEpoch}';
      _userData = {'facultyNumber': facultyNumber, 'email': email, 'name': 'Dr. Jane Smith', 'role': 'lecturer'};
      notifyListeners();
      return true;
    } catch (e) {
      print('Lecturer login error: $e');
      return false;
    }
  }

  // Admin login → mockup
  Future<bool> loginAdmin(String email, String password) async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      _isAuthenticated = true;
      _userRole = UserRole.admin;
      _token = 'admin_token_${DateTime.now().millisecondsSinceEpoch}';
      _userData = {'email': email, 'name': 'System Administrator', 'role': 'admin'};
      notifyListeners();
      return true;
    } catch (e) {
      print('Admin login error: $e');
      return false;
    }
  }

  // ===================== UPDATE & LOGOUT =====================
  void updateCurrentUser(Student updatedUser) {
    _currentUser = updatedUser;
    _userData = {
      'matricule': updatedUser.matriculeNumber,
      'email': updatedUser.email,
      'name': updatedUser.fullName,
      'role': updatedUser.role.toLowerCase(),
      'firstName': updatedUser.firstName,
      'lastName': updatedUser.lastName,
      'username': updatedUser.username,
      'department': updatedUser.department,
      'program': updatedUser.program,
    };
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _token = null;
    _userData = null;
    _userRole = null;
    _currentUser = null;
    notifyListeners();
  }
}
