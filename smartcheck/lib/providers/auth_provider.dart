import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;
  String? _userId;
  String? _userName;
  String? _userEmail;
  String? _userRole; // 'student' or 'lecturer'

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userRole => _userRole;

  // This is a placeholder for actual authentication logic
  // In a real app, this would make API calls to your backend
  Future<bool> login(String email, String password, String role) async {
    try {
      // TODO: Implement actual API call to backend with role parameter
      // Simulating successful login
      _isAuthenticated = true;
      _token = 'sample_token';
      _userId = '123';
      _userName = role == 'lecturer' ? 'Dr. Smith' : 'John Doe';
      _userEmail = email;
      _userRole = role;
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password, String role) async {
    try {
      // TODO: Implement actual API call to backend with role parameter
      // Simulating successful signup
      _isAuthenticated = true;
      _token = 'sample_token';
      _userId = '123';
      _userName = name;
      _userEmail = email;
      _userRole = role;
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Signup error: $e');
      return false;
    }
  }

  void logout() {
    _isAuthenticated = false;
    _token = null;
    _userId = null;
    _userName = null;
    _userEmail = null;
    _userRole = null;
    
    notifyListeners();
  }
}
