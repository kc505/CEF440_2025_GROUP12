import 'package:flutter/material.dart';
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

  // Student login with matricule number, email, and password
  Future<bool> loginStudent(String matricule, String email, String password) async {
    try {
      // TODO: Implement actual API call to backend for student login
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock successful login with proper Student model
      _isAuthenticated = true;
      _userRole = UserRole.student;
      _token = 'student_token_${DateTime.now().millisecondsSinceEpoch}';
      
      // Create current user with the new Student model structure
      _currentUser = Student(
        id: 'STU001',
        username: 'ash',
        password: password, // In real app, this would be hashed
        firstName: 'Mekole',
        lastName: 'Ashley',
        email: 'mekoleash@gmail.com',
        role: 'Student',
        phoneNumber: '677030466',
        registrationDate: DateTime.now().subtract(const Duration(days: 365)),
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
        'firstName': _currentUser!.firstName,
        'lastName': _currentUser!.lastName,
        'username': _currentUser!.username,
        'department': _currentUser!.department,
        'program': _currentUser!.program,
      };
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Student login error: $e');
      return false;
    }
  }

  // Lecturer login with faculty number, email, and password
  Future<bool> loginLecturer(String facultyNumber, String email, String password) async {
    try {
      // TODO: Implement actual API call to backend for lecturer login
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock successful login
      _isAuthenticated = true;
      _userRole = UserRole.lecturer;
      _token = 'lecturer_token_${DateTime.now().millisecondsSinceEpoch}';
      _userData = {
        'facultyNumber': facultyNumber,
        'email': email,
        'name': 'Dr. Jane Smith', // This would come from API response
        'role': 'lecturer',
      };
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Lecturer login error: $e');
      return false;
    }
  }

  // Admin login with email and password only
  Future<bool> loginAdmin(String email, String password) async {
    try {
      // TODO: Implement actual API call to backend for admin login
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock successful login
      _isAuthenticated = true;
      _userRole = UserRole.admin;
      _token = 'admin_token_${DateTime.now().millisecondsSinceEpoch}';
      _userData = {
        'email': email,
        'name': 'System Administrator', // This would come from API response
        'role': 'admin',
      };
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Admin login error: $e');
      return false;
    }
  }

  // Signup method (existing)
  Future<bool> signup(String name, String email, String password, String role) async {
    try {
      // TODO: Implement actual API call to backend with role parameter
      // Simulating successful signup
      _isAuthenticated = true;
      _token = 'sample_token';
      _userData = {
        'name': name,
        'email': email,
        'role': role,
      };
      
      // Set user role based on signup role
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
    } catch (e) {
      print('Signup error: $e');
      return false;
    }
  }

  // Update current user
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
    // TODO: Implement API call to invalidate token on backend
    _isAuthenticated = false;
    _token = null;
    _userData = null;
    _userRole = null;
    _currentUser = null;
    
    notifyListeners();
  }
}
