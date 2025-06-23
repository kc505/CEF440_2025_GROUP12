import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course.dart';
import '../../providers/course_provider.dart';
import '../../utils/app_theme.dart';

class ManageCoursesScreen extends StatefulWidget {
  const ManageCoursesScreen({Key? key}) : super(key: key);

  @override
  State<ManageCoursesScreen> createState() => _ManageCoursesScreenState();
}

class _ManageCoursesScreenState extends State<ManageCoursesScreen> {
  bool _isLoading = true;

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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddEditCourseDialog({Course? course}) {
    final _codeController = TextEditingController(text: course?.code ?? '');
    final _titleController = TextEditingController(text: course?.name ?? '');
    final _creditsController = TextEditingController(text: course?.credits.toString() ?? '3');
    final _dayOfWeekController = TextEditingController(text: course?.schedule?.dayOfWeek ?? 'Monday');
    final _timeController = TextEditingController(text: course?.schedule?.time ?? '09:00 - 11:00');
    final _latController = TextEditingController(text: course?.geofence?.lat.toString() ?? '4.056123');
    final _lngController = TextEditingController(text: course?.geofence?.lng.toString() ?? '9.700321');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(course == null ? 'Add Course' : 'Edit Course'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: _codeController, decoration: const InputDecoration(labelText: 'Course Code')),
                TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Course Title')),
                TextField(controller: _creditsController, decoration: const InputDecoration(labelText: 'Credits'), keyboardType: TextInputType.number),
                TextField(controller: _dayOfWeekController, decoration: const InputDecoration(labelText: 'Day of Week')),
                TextField(controller: _timeController, decoration: const InputDecoration(labelText: 'Time (e.g., 09:00 - 11:00)')),
                TextField(controller: _latController, decoration: const InputDecoration(labelText: 'Latitude'), keyboardType: TextInputType.number),
                TextField(controller: _lngController, decoration: const InputDecoration(labelText: 'Longitude'), keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final code = _codeController.text.trim();
                final name = _titleController.text.trim();
                final credits = int.tryParse(_creditsController.text.trim()) ?? 0;
                final lat = double.tryParse(_latController.text.trim()) ?? 0.0;
                final lng = double.tryParse(_lngController.text.trim()) ?? 0.0;
                final dayOfWeek = _dayOfWeekController.text.trim();
                final time = _timeController.text.trim();

                if (code.isEmpty || name.isEmpty || credits == 0 || dayOfWeek.isEmpty || time.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill all fields')));
                  return;
                }

                final newCourse = Course(
                  id: '',
                  code: code,
                  name: name,
                  credits: credits,
                  geofence: Geofence(lat: lat, lng: lng),
                  schedule: Schedule(dayOfWeek: dayOfWeek, time: time),
                );

                if (course == null) {
                  await Provider.of<CourseProvider>(context, listen: false).addCourse(newCourse);
                } else {
                  await Provider.of<CourseProvider>(context, listen: false).editCourse(course.id, newCourse);
                }

                Navigator.of(context).pop();
                _loadCourses();
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
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text('${course.code} - ${course.title}'),
                subtitle: Text(
                    'Lecturer: ${course.lecturerName ?? "Not Assigned"}'),
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
                        value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                        value: 'delete', child: Text('Delete')),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEditCourseDialog();
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
