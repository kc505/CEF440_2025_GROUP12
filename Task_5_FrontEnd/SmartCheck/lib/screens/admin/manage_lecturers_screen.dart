import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class ManageLecturersScreen extends StatefulWidget {
  const ManageLecturersScreen({Key? key}) : super(key: key);

  @override
  State<ManageLecturersScreen> createState() => _ManageLecturersScreenState();
}

class _ManageLecturersScreenState extends State<ManageLecturersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Manage Lecturers'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Text('Manage Lecturers - Coming Soon'),
      ),
    );
  }
}
