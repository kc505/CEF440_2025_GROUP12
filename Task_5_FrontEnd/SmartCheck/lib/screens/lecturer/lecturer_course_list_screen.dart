import 'package:flutter/material.dart';
import 'package:smartcheck/screens/lecturer/lecturer_course_detail_screen.dart';
import 'package:smartcheck/screens/lecturer/create_course_screen.dart';
import 'package:smartcheck/utils/app_theme.dart';
import 'package:smartcheck/models/course.dart';

class LecturerCourseListScreen extends StatefulWidget {
  const LecturerCourseListScreen({super.key});

  @override
  State<LecturerCourseListScreen> createState() => _LecturerCourseListScreenState();
}

class _LecturerCourseListScreenState extends State<LecturerCourseListScreen> {
  bool _isLoading = true;
  List<Course> _courses = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  // Simulated data loading
  Future<void> _loadCourses() async {
    // TODO: Replace with actual API call to fetch lecturer's courses
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
            department: 'Computer Engineering',
            totalStudents: 45,
            completedSessions: 8,
            totalSessions: 12,
            enrolledStudents: ['1', '2', '3', '4', '5'],
            createdAt: DateTime.now().subtract(const Duration(days: 90)),
          ),
          Course(
            id: '2',
            code: 'EEF470',
            name: 'Feedback Systems Laboratory',
            title: 'Feedback Systems Laboratory',
            description: 'Practical feedback systems implementation',
            credits: 3,
            status: 'Active',
            lecturerName: 'Dr. Smith',
            lecturerId: 'lec1',
            department: 'Electrical Engineering',
            totalStudents: 32,
            completedSessions: 6,
            totalSessions: 10,
            enrolledStudents: ['1', '3', '5', '7'],
            createdAt: DateTime.now().subtract(const Duration(days: 85)),
          ),
          Course(
            id: '3',
            code: 'CEF440',
            name: 'Internet Programming',
            title: 'Internet Programming',
            description: 'Web development technologies',
            credits: 3,
            status: 'Active',
            lecturerName: 'Dr. Smith',
            lecturerId: 'lec1',
            department: 'Computer Engineering',
            totalStudents: 38,
            completedSessions: 10,
            totalSessions: 14,
            enrolledStudents: ['2', '4', '6', '8'],
            createdAt: DateTime.now().subtract(const Duration(days: 80)),
          ),
          Course(
            id: '4',
            code: 'CEF450',
            name: 'Cloud Computing and SOA',
            title: 'Cloud Computing and Service-Oriented Architecture',
            description: 'Cloud computing concepts and SOA',
            credits: 3,
            status: 'Inactive',
            lecturerName: 'Dr. Smith',
            lecturerId: 'lec1',
            department: 'Computer Engineering',
            totalStudents: 28,
            completedSessions: 12,
            totalSessions: 12,
            enrolledStudents: ['1', '5', '9'],
            createdAt: DateTime.now().subtract(const Duration(days: 120)),
          ),
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
          : RefreshIndicator(
              onRefresh: _loadCourses,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'My Courses',
                            style: AppTheme.headingStyle,
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CreateCourseScreen(),
                                ),
                              ).then((_) => _loadCourses());
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Course'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Course statistics
                      _buildStatisticsCards(),
                      const SizedBox(height: 24),
                      
                      // Course list
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _courses.length,
                        itemBuilder: (context, index) {
                          final course = _courses[index];
                          return CourseCard(
                            course: course,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LecturerCourseDetailScreen(course: course),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateCourseScreen(),
            ),
          ).then((_) => _loadCourses());
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Courses',
            _courses.length.toString(),
            Icons.book,
            AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Active Courses',
            _courses.where((c) => c.status == 'Active').length.toString(),
            Icons.check_circle,
            AppTheme.successColor,
          ),
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
}

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    course.code.substring(0, 3),
                    style: TextStyle(
                      color: AppTheme.primaryColor,
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
                      '${course.code}: ${course.name}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${course.totalStudents ?? 0} students • ${course.completedSessions ?? 0}/${course.totalSessions ?? 0} sessions',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: course.status == 'Active'
                            ? AppTheme.successColor.withOpacity(0.1)
                            : AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        course.status ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 12,
                          color: course.status == 'Active'
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
