import 'package:flutter/material.dart';
import 'package:smartcheck/models/course.dart';
import 'package:smartcheck/screens/lecturer/create_session_screen.dart';
import 'package:smartcheck/screens/lecturer/attendance_report_screen.dart';
import 'package:smartcheck/screens/lecturer/attendance_analytics_screen.dart';
// import 'package:smartcheck/screens/lecturer/student_enrollment_screen.dart';
import 'package:smartcheck/utils/app_theme.dart';
import 'package:smartcheck/widgets/app_logo.dart';

class LecturerCourseDetailScreen extends StatefulWidget {
  final Course course;

  const LecturerCourseDetailScreen({
    super.key,
    required this.course,
  });

  @override
  State<LecturerCourseDetailScreen> createState() => _LecturerCourseDetailScreenState();
}

class _LecturerCourseDetailScreenState extends State<LecturerCourseDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _courseDetails = {};
  List<Map<String, dynamic>> _recentSessions = [];

  @override
  void initState() {
    super.initState();
    _loadCourseDetails();
  }

  // Simulated data loading
  Future<void> _loadCourseDetails() async {
    // TODO: Replace with actual API call to fetch course details
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _courseDetails = {
          'department': widget.course.department ?? 'Computer Engineering',
          'totalStudents': widget.course.totalStudents ?? 45,
          'averageAttendance': '85%',
          'totalSessions': widget.course.totalSessions ?? 12,
          'completedSessions': widget.course.completedSessions ?? 8,
        };
        
        _recentSessions = [
          {
            'id': '1',
            'date': 'May 15, 2025',
            'time': '10:00 AM',
            'venue': 'Room 101',
            'attendanceRate': '90%',
          },
          {
            'id': '2',
            'date': 'May 12, 2025',
            'time': '10:00 AM',
            'venue': 'Room 101',
            'attendanceRate': '85%',
          },
          {
            'id': '3',
            'date': 'May 8, 2025',
            'time': '10:00 AM',
            'venue': 'Room 101',
            'attendanceRate': '78%',
          },
        ];
        
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const AppLogo(height: 28),
            const SizedBox(width: 8),
            Text(widget.course.code),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                // TODO: Navigate to edit course screen
              } else if (value == 'delete') {
                _showDeleteConfirmation();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Edit Course'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: AppTheme.errorColor),
                    SizedBox(width: 8),
                    Text('Delete Course', style: TextStyle(color: AppTheme.errorColor)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course title
                    Text(
                      '${widget.course.code}: ${widget.course.name}',
                      style: AppTheme.headingStyle,
                    ),
                    const SizedBox(height: 24),
                    
                    // Course statistics
                    _buildStatisticsCards(),
                    const SizedBox(height: 24),
                    
                    // Quick actions
                    const Text(
                      'Quick Actions',
                      style: AppTheme.subheadingStyle,
                    ),
                    const SizedBox(height: 16),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    
                    // Recent sessions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Sessions',
                          style: AppTheme.subheadingStyle,
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Navigate to all sessions screen
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildRecentSessions(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateSessionScreen(course: widget.course),
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('New Session'),
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Students',
                _courseDetails['totalStudents'].toString(),
                Icons.people,
                AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Avg. Attendance',
                _courseDetails['averageAttendance'],
                Icons.check_circle,
                AppTheme.successColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Sessions',
                '${_courseDetails['completedSessions']}/${_courseDetails['totalSessions']}',
                Icons.calendar_today,
                AppTheme.accentColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Department',
                _courseDetails['department'],
                Icons.business,
                AppTheme.secondaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            'Create Session',
            Icons.add_circle,
            AppTheme.primaryColor,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateSessionScreen(course: widget.course),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            'Attendance Report',
            Icons.assessment,
            AppTheme.accentColor,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AttendanceReportScreen(course: widget.course),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSessions() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recentSessions.length,
      itemBuilder: (context, index) {
        final session = _recentSessions[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              'Session on ${session['date']}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Time: ${session['time']}'),
                Text('Venue: ${session['venue']}'),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text('Attendance: '),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        session['attendanceRate'],
                        style: const TextStyle(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: () {
                // TODO: Navigate to session details screen
              },
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Course'),
          content: Text('Are you sure you want to delete ${widget.course.code}: ${widget.course.name}? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Implement course deletion API call
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Course deleted successfully'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: AppTheme.errorColor),
              ),
            ),
          ],
        );
      },
    );
  }
}
