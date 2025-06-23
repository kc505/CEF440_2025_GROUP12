import 'package:flutter/material.dart';
import 'package:smartcheck/screens/course/course_detail_screen.dart';
import 'package:smartcheck/utils/app_theme.dart';
import 'package:smartcheck/models/course.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  bool _isLoading = true;
  List<Course> _courses = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  // Simulated data loading
  Future<void> _loadCourses() async {
    // TODO: Replace with actual API call to fetch courses
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _courses = [
          Course(
            id: '1',
            code: 'CEF472',
            name: 'Human Computer Interface',
            title: 'Human Computer Interface',
            description: 'Introduction to user interface design and human-computer interaction principles.',
            credits: 3,
            status: 'Ongoing',
          ),
          Course(
            id: '2',
            code: 'EEF470',
            name: 'Feedback Systems Laboratory',
            title: 'Feedback Systems Laboratory',
            description: 'Practical laboratory work on feedback control systems and automation.',
            credits: 4,
            status: 'Ongoing',
          ),
          Course(
            id: '3',
            code: 'CEF440',
            name: 'Internet Programming',
            title: 'Internet Programming',
            description: 'Web development technologies including HTML, CSS, JavaScript, and server-side programming.',
            credits: 3,
            status: 'Ongoing',
          ),
          Course(
            id: '4',
            code: 'CEF450',
            name: 'Cloud Computing and SOA',
            title: 'Cloud Computing and Service-Oriented Architecture',
            description: 'Introduction to cloud computing concepts, services, and service-oriented architecture.',
            credits: 3,
            status: 'Ongoing',
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
                      const Text(
                        'My Courses',
                        style: AppTheme.headingStyle,
                      ),
                      const SizedBox(height: 16),
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
                                  builder: (context) => CourseDetailScreen(course: course),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Course Analytics',
                        style: AppTheme.subheadingStyle,
                      ),
                      const SizedBox(height: 16),
                      _buildAnalyticsCard(),
                      const SizedBox(height: 16),
                      const Text(
                        'Dispute Status',
                        style: AppTheme.subheadingStyle,
                      ),
                      const SizedBox(height: 16),
                      _buildDisputeCard(),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to attendance check-in screen
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAnalyticsCard() {
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
            const Text(
              'Overall Attendance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildAttendanceIndicator(
                    'CEF472',
                    0.85,
                    AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAttendanceIndicator(
                    'EEF470',
                    0.75,
                    AppTheme.secondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAttendanceIndicator(
                    'CEF440',
                    0.92,
                    AppTheme.accentColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAttendanceIndicator(
                    'CEF450',
                    0.68,
                    Colors.amber,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceIndicator(String code, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          code,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 4),
        Text(
          '${(percentage * 100).toInt()}%',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDisputeCard() {
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
                const Text(
                  'Recent Disputes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to disputes screen
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildDisputeItem(
              'CEF472',
              'May 15, 2025',
              'Pending',
              Colors.amber,
            ),
            const Divider(),
            _buildDisputeItem(
              'EEF470',
              'May 10, 2025',
              'Approved',
              AppTheme.successColor,
            ),
            const Divider(),
            _buildDisputeItem(
              'CEF440',
              'May 5, 2025',
              'Rejected',
              AppTheme.errorColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisputeItem(String course, String date, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: statusColor,
              ),
            ),
          ),
        ],
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: course.status == 'Ongoing'
                            ? AppTheme.successColor.withOpacity(0.1)
                            : AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        course.status ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 12,
                          color: course.status == 'Ongoing'
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
