import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
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

  final String baseUrl = "http://localhost:5000/api"; // Update to production URL when needed

  // ===================== SIGNUP =====================
  Future<bool> signup(String firstName, String lastName, String email, String password, String role, String? department) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'role': role,
          'department': department,
        }),
      );

      if (response.statusCode == 201) {
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

  // ===================== LOGIN (Firebase Authentication) =====================
  Future<bool> loginWithFirebase(String email, String password, String role) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('User not found after login');
      }

      final idToken = await firebaseUser.getIdToken();

      _token = idToken;
      _isAuthenticated = true;

      _userData = {
        'uid': firebaseUser.uid,
        'email': firebaseUser.email,
        'displayName': firebaseUser.displayName,
        'emailVerified': firebaseUser.emailVerified,
        'phoneNumber': firebaseUser.phoneNumber,
        'photoURL': firebaseUser.photoURL,
      };

      // Set role
      switch (role.toLowerCase()) {
        case 'student':
          _userRole = UserRole.student;
          break;
        case 'lecturer':
          _userRole = UserRole.lecturer;
          break;
        case 'admin':
          _userRole = UserRole.admin;
          break;
        default:
          _userRole = UserRole.student;
      }

      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      print('Firebase Login error: ${e.code} → ${e.message}');
      return false;
    } catch (e) {
      print('Unexpected login error: $e');
      return false;
    }
  }

  // ===================== SPECIAL ADMIN LOGIN =====================
  void setAdminAuthenticated() {
    _isAuthenticated = true;
    _userRole = UserRole.admin;
    _userData = {
      'email': 'admin@smartcheck.com',
      'displayName': 'Admin User',
      'role': 'admin',
    };
    notifyListeners();
  }

  // ===================== FETCH USER PROFILE (/auth/me) =====================
  Future<bool> _fetchUserProfile(String idToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _userData = data;

        // Optionally populate _currentUser model from data
        _currentUser = Student.fromJson(data);

        return true;
      } else {
        print('Failed to fetch user profile: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      return false;
    }
  }

  // ===================== LOGOUT =====================
  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();

      if (_token != null) {
        await http.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: {
            'Authorization': 'Bearer $_token',
          },
        );
      }

      _isAuthenticated = false;
      _token = null;
      _userData = null;
      _userRole = null;
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      print('Logout error: $e');
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

  // ===================== UPDATE CURRENT USER (For UI updates) =====================
  void updateCurrentUser(Student updatedUser) {
    _currentUser = updatedUser;
    _userData = {
      'id': updatedUser.id,
      'matriculeNumber': updatedUser.matriculeNumber,
      'email': updatedUser.email,
      'firstName': updatedUser.firstName,
      'lastName': updatedUser.lastName,
      'role': updatedUser.role,
      'department': updatedUser.department,
      'program': updatedUser.program,
      'createdAt': updatedUser.createdAt?.toIso8601String(),
    };
    notifyListeners();
  }
}
