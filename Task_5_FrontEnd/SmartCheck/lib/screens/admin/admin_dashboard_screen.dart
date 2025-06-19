import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_logo.dart';
import '../auth/login_screen.dart';
import 'geofence_venues_screen.dart';
import 'manage_courses_screen.dart';
import 'manage_lecturers_screen.dart';
import 'manage_students_screen.dart';
import 'course_schedules_screen.dart';
import 'attendance_management_screen.dart';
import 'system_analytics_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final adminName = authProvider.userData?['name'] ?? 'Administrator';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 20),
                    const SizedBox(width: 8),
                    Text(adminName),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.1),
                    AppTheme.primaryColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const AppLogo(height: 60, width: 60),
                  const SizedBox(height: 12),
                  Text(
                    'Welcome, $adminName',
                    style: AppTheme.headingStyle.copyWith(
                      color: AppTheme.primaryColor,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'SmartCheck Administration Panel',
                    style: AppTheme.bodyStyle.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Core Management Section
            Text(
              'Core Management',
              style: AppTheme.headingStyle.copyWith(
                color: AppTheme.primaryColor,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.1,
              children: [
                _buildDashboardCard(
                  context,
                  'Geofence Venues',
                  'Manage attendance locations',
                  Icons.location_on,
                  Colors.blue,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GeofenceVenuesScreen(),
                    ),
                  ),
                ),
                _buildDashboardCard(
                  context,
                  'Manage Courses',
                  'Create and edit courses',
                  Icons.book,
                  Colors.green,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManageCoursesScreen(),
                    ),
                  ),
                ),
                _buildDashboardCard(
                  context,
                  'Manage Lecturers',
                  'Add and manage faculty',
                  Icons.person_outline,
                  Colors.orange,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManageLecturersScreen(),
                    ),
                  ),
                ),
                _buildDashboardCard(
                  context,
                  'Manage Students',
                  'Student administration',
                  Icons.group,
                  Colors.purple,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManageStudentsScreen(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            
            // Attendance Management Section
            Text(
              'Attendance Management',
              style: AppTheme.headingStyle.copyWith(
                color: AppTheme.primaryColor,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.1,
              children: [
                _buildDashboardCard(
                  context,
                  'Course Schedules',
                  'Manage class schedules',
                  Icons.schedule,
                  Colors.teal,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CourseSchedulesScreen(),
                    ),
                  ),
                ),
                _buildDashboardCard(
                  context,
                  'Attendance Control',
                  'Edit student attendance',
                  Icons.edit_calendar,
                  Colors.indigo,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AttendanceManagementScreen(),
                    ),
                  ),
                ),
                _buildDashboardCard(
                  context,
                  'System Analytics',
                  'View system reports',
                  Icons.analytics,
                  Colors.red,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SystemAnalyticsScreen(),
                    ),
                  ),
                ),
                _buildDashboardCard(
                  context,
                  'System Settings',
                  'Configure system',
                  Icons.settings,
                  Colors.grey,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('System Settings - Coming Soon')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTheme.bodyStyle.copyWith(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
