import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../models/course.dart';
import '../../models/attendance_session.dart';
import '../../widgets/custom_button.dart';
import 'course_students_screen.dart';
import 'edit_session_attendance_screen.dart';

class AttendanceManagementScreen extends StatefulWidget {
  const AttendanceManagementScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceManagementScreen> createState() => _AttendanceManagementScreenState();
}

class _AttendanceManagementScreenState extends State<AttendanceManagementScreen> {
  bool _isLoading = true;
  List<Course> _courses = [];
  List<AttendanceSession> _recentSessions = [];
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // TODO: Replace with actual API calls
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _courses = [
          Course(
            id: '1',
            code: 'CEF472',
            name: 'Human Computer Interface',
            title: 'Human Computer Interface',
            description: 'Introduction to HCI principles and design',
            credits: 3,
            status: 'Active',
            lecturerName: 'Dr. Smith',
            lecturerId: 'lec1',
            enrolledStudents: ['1', '2', '3', '4', '5'],
            totalStudents: 5,
            completedSessions: 8,
            totalSessions: 12,
            department: 'Computer Engineering',
            createdAt: DateTime.now().subtract(const Duration(days: 90)),
          ),
          Course(
            id: '2',
            code: 'EEF470',
            name: 'Feedback Systems Laboratory',
            title: 'Feedback Systems Laboratory',
            description: 'Practical feedback systems implementation',
            credits: 2,
            status: 'Active',
            lecturerName: 'Prof. Johnson',
            lecturerId: 'lec2',
            enrolledStudents: ['1', '3', '5', '7', '9'],
            totalStudents: 5,
            completedSessions: 6,
            totalSessions: 10,
            department: 'Electrical Engineering',
            createdAt: DateTime.now().subtract(const Duration(days: 85)),
          ),
        ];
        
        _recentSessions = [
          AttendanceSession(
            id: '1',
            courseId: '1',
            courseName: 'Human Computer Interface',
            courseCode: 'CEF472',
            sessionDate: DateTime.now().subtract(const Duration(days: 1)),
            startTime: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
            endTime: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
            venueId: '1',
            venueName: 'Room A101',
            lecturerId: '1',
            lecturerName: 'Dr. Smith',
            attendances: [],
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            attendancePercentage: 85,
          ),
        ];
        
        _isLoading = false;
      });
    }
  }

  List<Course> get _filteredCourses {
    if (_selectedFilter == 'All') return _courses;
    if (_selectedFilter == 'Active') return _courses.where((course) => course.status == 'Active').toList();
    if (_selectedFilter == 'Completed') return _courses.where((course) => course.status == 'Completed').toList();
    return _courses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Attendance Management'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterSection(),
                  const SizedBox(height: 24),
                  _buildCoursesSection(),
                  const SizedBox(height: 24),
                  _buildRecentSessionsSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildFilterSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Courses',
              style: AppTheme.subheadingStyle,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['All', 'Active', 'Completed'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedFilter = filter);
                  },
                  backgroundColor: Colors.grey[100],
                  selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? AppTheme.primaryColor : Colors.grey[700],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Courses',
          style: AppTheme.headingStyle.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredCourses.length,
          itemBuilder: (context, index) {
            final course = _filteredCourses[index];
            return _buildCourseCard(course);
          },
        ),
      ],
    );
  }

  Widget _buildCourseCard(Course course) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    course.code,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${course.enrolledStudents?.length ?? 0} Students',
                  style: AppTheme.captionStyle,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              course.name,
              style: AppTheme.subheadingStyle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Lecturer: ${course.lecturerName ?? 'Not Assigned'}',
              style: AppTheme.captionStyle,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseStudentsScreen(course: course),
                        ),
                      );
                    },
                    icon: const Icon(Icons.group, size: 16),
                    label: const Text('View Students'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to course sessions
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Course sessions - Coming Soon')),
                      );
                    },
                    icon: const Icon(Icons.schedule, size: 16),
                    label: const Text('Sessions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSessionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Sessions',
              style: AppTheme.headingStyle.copyWith(fontSize: 18),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to all sessions
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _recentSessions.isEmpty
            ? Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_note,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No recent sessions',
                          style: AppTheme.bodyStyle.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentSessions.length,
                itemBuilder: (context, index) {
                  final session = _recentSessions[index];
                  return _buildSessionCard(session);
                },
              ),
      ],
    );
  }

  Widget _buildSessionCard(AttendanceSession session) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Create a course object for the session
          final course = Course(
            id: session.courseId,
            code: session.courseCode,
            name: session.courseName,
            title: session.courseName,
            description: 'Course description',
            credits: 3,
            status: 'Active',
            lecturerName: session.lecturerName,
            lecturerId: session.lecturerId,
          );
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditSessionAttendanceScreen(course: course),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${session.courseCode}: ${session.courseName}',
                      style: AppTheme.subheadingStyle.copyWith(fontSize: 16),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    session.venueName,
                    style: AppTheme.captionStyle,
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    session.lecturerName,
                    style: AppTheme.captionStyle,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${session.sessionDate.day}/${session.sessionDate.month}/${session.sessionDate.year}',
                    style: AppTheme.captionStyle,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: session.attendancePercentage >= 75
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${session.attendancePercentage.toInt()}% Present',
                      style: TextStyle(
                        fontSize: 12,
                        color: session.attendancePercentage >= 75
                            ? Colors.green[700]
                            : Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
