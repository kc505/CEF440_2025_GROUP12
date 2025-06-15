import 'package:flutter/material.dart';
import 'package:smartcheck/screens/lecturer/create_session_screen.dart';
import 'package:smartcheck/utils/app_theme.dart';
import 'package:smartcheck/models/course.dart';

class LecturerSessionsScreen extends StatefulWidget {
  const LecturerSessionsScreen({super.key});

  @override
  State<LecturerSessionsScreen> createState() => _LecturerSessionsScreenState();
}

class _LecturerSessionsScreenState extends State<LecturerSessionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _upcomingSessions = [];
  List<Map<String, dynamic>> _pastSessions = [];
  List<Course> _courses = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSessions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Simulated data loading
  Future<void> _loadSessions() async {
    // TODO: Replace with actual API call to fetch sessions
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _courses = [
          Course(id: '1', code: 'CEF472', name: 'Human Computer Interface', status: 'Active'),
          Course(id: '2', code: 'EEF470', name: 'Feedback Systems Laboratory', status: 'Active'),
          Course(id: '3', code: 'CEF440', name: 'Internet Programming', status: 'Active'),
        ];
        
        _upcomingSessions = [
          {
            'id': '1',
            'course': 'EEF470',
            'courseName': 'Feedback Systems Laboratory',
            'date': 'May 16, 2025',
            'time': '2:00 PM',
            'venue': 'Lab 2',
            'duration': '90 minutes',
            'status': 'Scheduled',
          },
          {
            'id': '2',
            'course': 'CEF440',
            'courseName': 'Internet Programming',
            'date': 'May 17, 2025',
            'time': '10:00 AM',
            'venue': 'Room 203',
            'duration': '60 minutes',
            'status': 'Scheduled',
          },
        ];
        
        _pastSessions = [
          {
            'id': '3',
            'course': 'CEF472',
            'courseName': 'Human Computer Interface',
            'date': 'May 15, 2025',
            'time': '10:00 AM',
            'venue': 'Room 101',
            'duration': '60 minutes',
            'status': 'Completed',
            'attendanceRate': '90%',
            'presentStudents': 36,
            'totalStudents': 40,
          },
          {
            'id': '4',
            'course': 'EEF470',
            'courseName': 'Feedback Systems Laboratory',
            'date': 'May 12, 2025',
            'time': '2:00 PM',
            'venue': 'Lab 2',
            'duration': '90 minutes',
            'status': 'Completed',
            'attendanceRate': '85%',
            'presentStudents': 34,
            'totalStudents': 40,
          },
        ];
        
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
          : Column(
              children: [
                // Header with create session button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sessions',
                        style: AppTheme.headingStyle,
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showCreateSessionDialog();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('New Session'),
                      ),
                    ],
                  ),
                ),
                
                // Tab bar
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Upcoming'),
                    Tab(text: 'Past Sessions'),
                  ],
                  indicatorColor: AppTheme.primaryColor,
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: AppTheme.textSecondaryColor,
                ),
                
                // Tab views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildUpcomingSessionsTab(),
                      _buildPastSessionsTab(),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateSessionDialog();
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildUpcomingSessionsTab() {
    return RefreshIndicator(
      onRefresh: _loadSessions,
      child: _upcomingSessions.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.schedule,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No upcoming sessions',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _upcomingSessions.length,
              itemBuilder: (context, index) {
                final session = _upcomingSessions[index];
                return _buildUpcomingSessionCard(session);
              },
            ),
    );
  }

  Widget _buildPastSessionsTab() {
    return RefreshIndicator(
      onRefresh: _loadSessions,
      child: _pastSessions.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No past sessions',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _pastSessions.length,
              itemBuilder: (context, index) {
                final session = _pastSessions[index];
                return _buildPastSessionCard(session);
              },
            ),
    );
  }

  Widget _buildUpcomingSessionCard(Map<String, dynamic> session) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
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
                Text(
                  '${session['course']}: ${session['courseName']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    session['status'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondaryColor),
                const SizedBox(width: 8),
                Text(
                  '${session['date']} at ${session['time']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: AppTheme.textSecondaryColor),
                const SizedBox(width: 8),
                Text(
                  session['venue'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.timer, size: 16, color: AppTheme.textSecondaryColor),
                const SizedBox(width: 8),
                Text(
                  session['duration'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Edit session
                    },
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Start session
                    },
                    child: const Text('Start Session'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPastSessionCard(Map<String, dynamic> session) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
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
                Text(
                  '${session['course']}: ${session['courseName']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    session['status'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.successColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondaryColor),
                const SizedBox(width: 8),
                Text(
                  '${session['date']} at ${session['time']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: AppTheme.textSecondaryColor),
                const SizedBox(width: 8),
                Text(
                  session['venue'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Attendance: ${session['attendanceRate']}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.successColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${session['presentStudents']}/${session['totalStudents']} students',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: View details
                    },
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Edit attendance
                    },
                    child: const Text('Edit Attendance'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateSessionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Course'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _courses.map((course) {
              return ListTile(
                title: Text('${course.code}: ${course.name}'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateSessionScreen(course: course),
                    ),
                  ).then((_) => _loadSessions());
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
