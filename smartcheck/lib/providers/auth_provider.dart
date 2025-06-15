import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Constructor to load saved data
  AuthProvider() {
    _loadUserData();
  }

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
      
      // Save user data
      await _saveUserData();
      
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
      
      // Save user data
      await _saveUserData();
      
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
    
    // Clear saved data
    _clearUserData();
    
    notifyListeners();
  }

  // ===== ADDITIONAL METHODS FOR PROFILE MANAGEMENT =====

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('is_authenticated') ?? false;
    _token = prefs.getString('token');
    _userId = prefs.getString('user_id');
    _userName = prefs.getString('user_name');
    _userEmail = prefs.getString('user_email');
    _userRole = prefs.getString('user_role');
    notifyListeners();
  }

  // Save user data to SharedPreferences
  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_authenticated', _isAuthenticated);
    if (_token != null) await prefs.setString('token', _token!);
    if (_userId != null) await prefs.setString('user_id', _userId!);
    if (_userName != null) await prefs.setString('user_name', _userName!);
    if (_userEmail != null) await prefs.setString('user_email', _userEmail!);
    if (_userRole != null) await prefs.setString('user_role', _userRole!);
  }

  // Clear user data from SharedPreferences
  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Update user name
  Future<void> updateUserName(String newName) async {
    _userName = newName;
    await _saveUserData();
    notifyListeners();
  }

  // Update user email
  Future<void> updateUserEmail(String newEmail) async {
    _userEmail = newEmail;
    await _saveUserData();
    notifyListeners();
  }

  // Check authentication status (for app initialization)
  Future<bool> checkAuthStatus() async {
    await _loadUserData();
    return _isAuthenticated;
  }
}