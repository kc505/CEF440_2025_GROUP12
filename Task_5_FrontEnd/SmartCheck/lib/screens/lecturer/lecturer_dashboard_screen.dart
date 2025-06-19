import 'package:flutter/material.dart';
import 'package:smartcheck/utils/app_theme.dart';

class LecturerDashboardScreen extends StatefulWidget {
  const LecturerDashboardScreen({super.key});

  @override
  State<LecturerDashboardScreen> createState() => _LecturerDashboardScreenState();
}

class _LecturerDashboardScreenState extends State<LecturerDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _dashboardData = {};

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // Simulated data loading
  Future<void> _loadDashboardData() async {
    // TODO: Replace with actual API call to fetch dashboard data
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _dashboardData = {
          'totalCourses': 4,
          'totalStudents': 180,
          'averageAttendance': 82.5,
          'activeSessions': 2,
          'todaysSessions': [
            {'course': 'CEF472', 'time': '10:00 AM', 'venue': 'Room 101', 'status': 'Completed'},
            {'course': 'EEF470', 'time': '2:00 PM', 'venue': 'Lab 2', 'status': 'Upcoming'},
          ],
          'recentActivity': [
            {'type': 'session', 'course': 'CEF472', 'action': 'Session completed', 'time': '2 hours ago'},
            {'type': 'attendance', 'course': 'EEF470', 'action': 'Attendance edited', 'time': '4 hours ago'},
            {'type': 'session', 'course': 'CEF440', 'action': 'Session created', 'time': '1 day ago'},
          ],
          'weeklyAttendance': [
            {'day': 'Mon', 'rate': 0.85},
            {'day': 'Tue', 'rate': 0.78},
            {'day': 'Wed', 'rate': 0.92},
            {'day': 'Thu', 'rate': 0.88},
            {'day': 'Fri', 'rate': 0.75},
          ],
        };
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dashboard',
                        style: AppTheme.headingStyle,
                      ),
                      const SizedBox(height: 20),
                      
                      // Statistics cards
                      _buildStatisticsCards(),
                      const SizedBox(height: 24),
                      
                      // Weekly attendance chart
                      const Text(
                        'Weekly Attendance Overview',
                        style: AppTheme.subheadingStyle,
                      ),
                      const SizedBox(height: 16),
                      _buildAttendanceChart(),
                      const SizedBox(height: 24),
                      
                      // Today's sessions
                      const Text(
                        "Today's Sessions",
                        style: AppTheme.subheadingStyle,
                      ),
                      const SizedBox(height: 16),
                      _buildTodaysSessions(),
                      const SizedBox(height: 24),
                      
                      // Recent activity
                      const Text(
                        'Recent Activity',
                        style: AppTheme.subheadingStyle,
                      ),
                      const SizedBox(height: 16),
                      _buildRecentActivity(),
                    ],
                  ),
                ),
              ),
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
                'Total Courses',
                _dashboardData['totalCourses'].toString(),
                Icons.book,
                AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Total Students',
                _dashboardData['totalStudents'].toString(),
                Icons.people,
                AppTheme.accentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Avg. Attendance',
                '${_dashboardData['averageAttendance']}%',
                Icons.check_circle,
                AppTheme.successColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Active Sessions',
                _dashboardData['activeSessions'].toString(),
                Icons.schedule,
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
                    fontSize: 24,
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

  Widget _buildAttendanceChart() {
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
            Text(
              '${_dashboardData['averageAttendance']}%',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Average This Week',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            
            // Simple bar chart representation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _dashboardData['weeklyAttendance'].map<Widget>((dayData) {
                return _buildChartBar(dayData['day'], dayData['rate']);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartBar(String label, double value) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 100 * value,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTodaysSessions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: _dashboardData['todaysSessions'].map<Widget>((session) {
            final isCompleted = session['status'] == 'Completed';
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? AppTheme.successColor.withOpacity(0.1)
                          : AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        session['course'].substring(0, 3),
                        style: TextStyle(
                          color: isCompleted ? AppTheme.successColor : AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session['course'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${session['time']} • ${session['venue']}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? AppTheme.successColor.withOpacity(0.1)
                          : AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      session['status'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isCompleted ? AppTheme.successColor : AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: _dashboardData['recentActivity'].map<Widget>((activity) {
            IconData icon;
            Color iconColor;
            
            switch (activity['type']) {
              case 'session':
                icon = Icons.schedule;
                iconColor = AppTheme.primaryColor;
                break;
              case 'attendance':
                icon = Icons.edit;
                iconColor = AppTheme.accentColor;
                break;
              default:
                icon = Icons.info;
                iconColor = AppTheme.textSecondaryColor;
            }
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${activity['course']}: ${activity['action']}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activity['time'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
