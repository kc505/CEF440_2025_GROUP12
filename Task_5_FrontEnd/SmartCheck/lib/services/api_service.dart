import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  static Future<List<dynamic>> getUsersByRole(String role) async {
    final response = await http.get(Uri.parse('$baseUrl/users?role=$role'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load users');
    }
  }

  static Future<void> createLecturer(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to create lecturer: ${response.body}');
    }
  }

  static Future<List<dynamic>> getCourses() async {
  final response = await http.get(Uri.parse('$baseUrl/courses'));
  if (response.statusCode == 200) {
  return jsonDecode(response.body);
  } else {
  throw Exception('Failed to load courses');
  }
  }

  static Future<void> createCourse(Map<String, dynamic> courseData) async {
  final response = await http.post(
  Uri.parse('$baseUrl/courses'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode(courseData),
  );
  if (response.statusCode != 201) {
  throw Exception('Failed to create course');
  }
  }

  static Future<void> updateCourse(String courseId, Map<String, dynamic> courseData) async {
  final response = await http.put(
  Uri.parse('$baseUrl/courses/$courseId'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode(courseData),
  );
  if (response.statusCode != 200) {
  throw Exception('Failed to update course');
  }
  }

  static Future<void> deleteCourse(String courseId) async {
  final response = await http.delete(Uri.parse('$baseUrl/courses/$courseId'));
  if (response.statusCode != 200) {
  throw Exception('Failed to delete course');
  }
  }

  static Future<void> assignLecturer(String courseId, String lecturerId) async {
  final response = await http.patch(
  Uri.parse('$baseUrl/courses/$courseId/assign-lecturer'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'lecturerId': lecturerId}),
  );
  if (response.statusCode != 200) {
  throw Exception('Failed to assign lecturer');
  }
  }
  }
