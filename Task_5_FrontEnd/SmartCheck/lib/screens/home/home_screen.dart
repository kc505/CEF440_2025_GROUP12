import 'package:flutter/material.dart';
import 'package:smartcheck/screens/course/course_list_screen.dart';
import 'package:smartcheck/screens/dashboard/dashboard_screen.dart';
import 'package:smartcheck/screens/profile/profile_screen.dart';
import 'package:smartcheck/screens/dispute/dispute_screen.dart';
import 'package:smartcheck/screens/notifications/notifications_screen.dart';
import 'package:smartcheck/utils/app_theme.dart';
import 'package:smartcheck/widgets/app_logo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const CourseListScreen(),
    const DashboardScreen(),
    const ProfileScreen(),
    const DisputeScreen(),
  ];

  void _showJoinClassDialog() {
    final TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Join Class'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter the class code to join:'),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'Class Code',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., ABC123',
                ),
                textCapitalization: TextCapitalization.characters,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (codeController.text.isNotEmpty) {
                  // Handle join class logic here
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Joining class with code: ${codeController.text}'),
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a class code'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Join'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'SmartCheck',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        leadingWidth: 120,
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showJoinClassDialog,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: 'Dispute',
          ),
        ],
      ),
    );
  }
}