import 'package:flutter/material.dart';
import '../models/course.dart';
import '../services/api_service.dart';

class CourseProvider with ChangeNotifier {
  List<Course> _courses = [];

  List<Course> get courses => _courses;

  Future<void> fetchCourses() async {
    final data = await ApiService.getCourses();
    _courses = data;
    notifyListeners();
  }

  Future<void> addCourse(Course course) async {
    await ApiService.createCourse(course.toJson());
    await fetchCourses(); // Refresh list
  }

  Future<void> editCourse(String id, Course course) async {
    await ApiService.updateCourse(id, course.toJson());
    await fetchCourses(); // Refresh list
  }

  Future<void> removeCourse(String id) async {
    await ApiService.deleteCourse(id);
    _courses.removeWhere((course) => course.id == id);
    notifyListeners();
  }

  Future<void> assignLecturer(String courseId, String lecturerId) async {
    await ApiService.assignLecturer(courseId, lecturerId);
    await fetchCourses(); // Refresh list
  }
}
