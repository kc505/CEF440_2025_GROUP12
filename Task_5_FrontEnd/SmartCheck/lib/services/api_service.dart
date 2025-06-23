import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/course.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  static Future<List<Map<String, dynamic>>> getUsersByRole(String role) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$role'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load users');
    }
  }

  static Future<Map<String, dynamic>> createLecturer(
      Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/lecturer'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create lecturer: ${response.body}');
    }
  }

  static Future<List<Course>> getCourses() async {
    final response = await http.get(Uri.parse('$baseUrl/courses'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => Course.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load courses');
    }
  }

  static Future<void> assignLecturer(String courseId, String lecturerId) async {
    final url = Uri.parse('$baseUrl/courses/$courseId/assign-lecturer');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'lecturerId': lecturerId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to assign lecturer');
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

  static Future<void> updateCourse(String courseId,
      Map<String, dynamic> courseData) async {
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
}

