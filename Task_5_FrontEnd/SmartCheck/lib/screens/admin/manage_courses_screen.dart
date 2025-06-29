import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/course.dart';
import '../../models/lecturer.dart';
import '../../providers/course_provider.dart';
import '../../utils/app_theme.dart';

class ManageCoursesScreen extends StatefulWidget {
  const ManageCoursesScreen({Key? key}) : super(key: key);

  @override
  State<ManageCoursesScreen> createState() => _ManageCoursesScreenState();
}

class _ManageCoursesScreenState extends State<ManageCoursesScreen> {
  bool _isLoading = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);
    try {
      await Provider.of<CourseProvider>(context, listen: false).fetchCourses();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<Lecturer?> _fetchLecturer(String? userId) async {
    if (userId == null || userId.isEmpty) return null;

    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return Lecturer(
          userId: doc.id,
          firstName: doc['firstName'] ?? '',
          lastName: doc['lastName'] ?? '',
          email: doc['email'] ?? '',
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching lecturer: $e');
      return null;
    }
  }

  void _showAddEditCourseDialog({Course? course}) {
    final _codeController = TextEditingController(text: course?.code ?? '');
    final _titleController = TextEditingController(text: course?.name ?? '');
    final _creditsController = TextEditingController(
      text: course?.credits.toString() ?? '3',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(course == null ? 'Add Course' : 'Edit Course'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _codeController,
                  decoration: const InputDecoration(labelText: 'Course Code'),
                ),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Course Title'),
                ),
                TextField(
                  controller: _creditsController,
                  decoration: const InputDecoration(labelText: 'Credits'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final code = _codeController.text.trim();
                final name = _titleController.text.trim();
                final credits = int.tryParse(_creditsController.text.trim()) ?? 0;

                if (code.isEmpty || name.isEmpty || credits == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }

                final newCourse = Course(
                  id: course?.id ?? '',
                  code: code,
                  name: name,
                  credits: credits,
                  lecturerId: course?.lecturerId,
                );

                try {
                  if (course == null) {
                    await Provider.of<CourseProvider>(context, listen: false)
                        .addCourse(newCourse);
                  } else {
                    await Provider.of<CourseProvider>(context, listen: false)
                        .editCourse(course.id, newCourse);
                  }
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final courses = Provider.of<CourseProvider>(context).courses;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Manage Courses'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCourses,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadCourses,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return FutureBuilder<Lecturer?>(
              future: _fetchLecturer(course.lecturerId),
              builder: (context, snapshot) {
                final lecturerName = snapshot.hasData
                    ? '${snapshot.data!.firstName} ${snapshot.data!.lastName}'.trim()
                    : 'Not Assigned';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text('${course.code} - ${course.name}'),
                    subtitle: Text('Lecturer: $lecturerName'),
                    trailing: PopupMenuButton(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showAddEditCourseDialog(course: course);
                        } else if (value == 'delete') {
                          Provider.of<CourseProvider>(context, listen: false)
                              .removeCourse(course.id);
                        }
                      },
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
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditCourseDialog(),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}