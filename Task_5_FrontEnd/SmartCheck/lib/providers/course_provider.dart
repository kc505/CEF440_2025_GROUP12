import 'package:flutter/material.dart';
import '../models/course.dart';
import '../services/api_service.dart';

class CourseProvider with ChangeNotifier {
  List<Course> _courses = [];
  bool _isLoading = false;
  String? _error;

  List<Course> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCourses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ApiService.getCourses();
      _courses = data;
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to fetch courses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCourse(Course course) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.createCourse(course.toJson());
      await fetchCourses();
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to add course: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> editCourse(String id, Course course) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.updateCourse(id, course.toJson());
      await fetchCourses();
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to edit course: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeCourse(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.deleteCourse(id);
      await fetchCourses();
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to delete course: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> assignLecturer(String courseId, String lecturerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.assignLecturer(courseId, lecturerId);

      // Update locally for immediate UI feedback
      final index = _courses.indexWhere((c) => c.id == courseId);
      if (index != -1) {
        _courses[index] = _courses[index].copyWith(lecturerId: lecturerId);
        notifyListeners();
      }

      await fetchCourses(); // Then refresh from server
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to assign lecturer: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}