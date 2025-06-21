import 'package:flutter/material.dart';
import 'package:smartcheck/screens/lecturer/lecturer_course_list_screen.dart';
import 'package:smartcheck/screens/lecturer/lecturer_dashboard_screen.dart';
import 'package:smartcheck/screens/lecturer/lecturer_profile_screen.dart';
import 'package:smartcheck/screens/lecturer/lecturer_sessions_screen.dart';
import 'package:smartcheck/screens/notifications/notifications_screen.dart';
import 'package:smartcheck/utils/app_theme.dart';
import 'package:smartcheck/widgets/app_logo.dart';

class LecturerHomeScreen extends StatefulWidget {
  const LecturerHomeScreen({super.key});

  @override
  State<LecturerHomeScreen> createState() => _LecturerHomeScreenState();
}

class _LecturerHomeScreenState extends State<LecturerHomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const LecturerCourseListScreen(),
    const LecturerDashboardScreen(),
    const LecturerSessionsScreen(),
    const LecturerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Lecturer'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondaryColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Sessions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
