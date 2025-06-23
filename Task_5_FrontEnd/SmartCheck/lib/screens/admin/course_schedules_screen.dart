import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class CourseSchedulesScreen extends StatefulWidget {
  const CourseSchedulesScreen({Key? key}) : super(key: key);

  @override
  State<CourseSchedulesScreen> createState() => _CourseSchedulesScreenState();
}

class _CourseSchedulesScreenState extends State<CourseSchedulesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Course Schedules'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Text('Course Schedules - Coming Soon'),
      ),
    );
  }
}
