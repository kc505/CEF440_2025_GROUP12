import 'package:flutter/material.dart';
import '../../models/course.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_text_field.dart';

class ManageLecturersScreen extends StatefulWidget {
  const ManageLecturersScreen({Key? key}) : super(key: key);

  @override
  State<ManageLecturersScreen> createState() => _ManageLecturersScreenState();
}

class _ManageLecturersScreenState extends State<ManageLecturersScreen> {
  final List<Course> _courses = [];
  final List<Map<String, dynamic>> _lecturers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await _loadCourses();
      await _loadLecturers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCourses() async {
    final courses = await ApiService.getCourses();
    setState(() {
      _courses.clear();
      _courses.addAll(courses);
    });
  }

  Future<void> _loadLecturers() async {
    final lecturers = await ApiService.getUsersByRole('lecturer');

    final lecturersWithCourses = lecturers.map((lecturer) {
      Course? assignedCourse;
      try {
        assignedCourse = _courses.firstWhere(
              (course) =>
          course.lecturerId == lecturer['userID'] ||
              course.lecturerId == lecturer['id'],
        );
      } catch (e) {
        assignedCourse = null;
      }

      return {
        ...lecturer,
        'assignedCourse': assignedCourse,
      };
    }).toList();

    setState(() {
      _lecturers.clear();
      _lecturers.addAll(lecturersWithCourses);
    });
  }

  void _showAddLecturerDialog() {
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    String? selectedCourseId;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Lecturer'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                CustomTextField(label: 'Full Name', controller: _nameController),
                const SizedBox(height: 10),
                CustomTextField(label: 'Email', controller: _emailController),
                const SizedBox(height: 10),
                CustomTextField(
                    label: 'Password',
                    controller: _passwordController,
                    obscureText: true),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Assign to Course'),
                  value: selectedCourseId,
                  items: _courses.map((course) {
                    return DropdownMenuItem<String>(
                      value: course.id,
                      child: Text('${course.code} - ${course.name}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedCourseId = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                final email = _emailController.text.trim();
                final password = _passwordController.text.trim();

                if (name.isEmpty || email.isEmpty || password.isEmpty || selectedCourseId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (mounted) setState(() => _isLoading = true);

                try {
                  final nameParts = name.split(' ');
                  final firstName = nameParts.first;
                  final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

                  final createdLecturer = await ApiService.createLecturer({
                    "firstName": firstName,
                    "lastName": lastName,
                    "email": email,
                    "password": password,
                    "role": "lecturer",
                    "department": null,
                  });

                  final lecturerId = createdLecturer['userID'] ?? createdLecturer['id'] ?? '';
                  if (lecturerId.isEmpty) throw Exception('Lecturer ID missing from response');

                  await ApiService.assignLecturer(selectedCourseId!, lecturerId);
                  await _loadLecturers();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Lecturer "$name" created & assigned successfully!'),
                          backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Manage Lecturers'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadLecturers,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _lecturers.length,
          itemBuilder: (context, index) {
            final lecturer = _lecturers[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text('${lecturer['firstName']} ${lecturer['lastName']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lecturer['email'] ?? ''),
                    Text('Role: ${lecturer['role']}'),
                    if (lecturer['assignedCourse'] != null)
                      Text(
                          'Course: ${lecturer['assignedCourse'].code} - ${lecturer['assignedCourse'].name}'),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLecturerDialog,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
