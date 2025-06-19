import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../models/course.dart';

class ManageCoursesScreen extends StatefulWidget {
  const ManageCoursesScreen({Key? key}) : super(key: key);

  @override
  State<ManageCoursesScreen> createState() => _ManageCoursesScreenState();
}

class _ManageCoursesScreenState extends State<ManageCoursesScreen> {
  List<Course> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Implement API call to fetch courses
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      _courses = [
        Course(
          id: '1',
          code: 'CSC101',
          name: 'Introduction to Computer Science',
          title: 'Introduction to Computer Science',
          description: 'Basic concepts of computer science',
          credits: 3,
          status: 'Active',
          lecturerName: 'Dr. Smith',
          lecturerId: 'lec1',
          department: 'Computer Science',
          totalStudents: 45,
          completedSessions: 8,
          totalSessions: 12,
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
        ),
        Course(
          id: '2',
          code: 'MAT201',
          name: 'Calculus II',
          title: 'Calculus II',
          description: 'Advanced calculus concepts',
          credits: 4,
          status: 'Active',
          lecturerName: 'Prof. Johnson',
          lecturerId: 'lec2',
          department: 'Mathematics',
          totalStudents: 38,
          completedSessions: 10,
          totalSessions: 15,
          createdAt: DateTime.now().subtract(const Duration(days: 55)),
        ),
      ];
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading courses: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Manage Courses'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                final course = _courses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      child: Text(
                        course.code.substring(0, 2),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text('${course.code} - ${course.title}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Credits: ${course.credits}'),
                        Text('Lecturer: ${course.lecturerName ?? 'Not Assigned'}'),
                        Text('Students: ${course.totalStudents ?? 0}'),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                      onSelected: (value) {
                        // TODO: Implement edit/delete functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$value course - Coming Soon')),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add course screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add Course - Coming Soon')),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
