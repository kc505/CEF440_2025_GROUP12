import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../utils/app_theme.dart';

class SystemAnalyticsScreen extends StatefulWidget {
  const SystemAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<SystemAnalyticsScreen> createState() => _SystemAnalyticsScreenState();
}

class _SystemAnalyticsScreenState extends State<SystemAnalyticsScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _analyticsData = {};

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Implement API call to fetch system analytics
      // final response = await http.get(
      //   Uri.parse('${ApiConstants.baseUrl}/admin/analytics'),
      //   headers: {'Authorization': 'Bearer ${authProvider.token}'},
      // );
      
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock analytics data
      _analyticsData = {
        'totalStudents': 1250,
        'totalLecturers': 45,
        'totalCourses': 78,
        'totalSessions': 324,
        'averageAttendance': 82.5,
        'activeVenues': 12,
        'monthlyAttendance': [
          {'month': 'Jan', 'attendance': 78.5},
          {'month': 'Feb', 'attendance': 82.1},
          {'month': 'Mar', 'attendance': 85.3},
          {'month': 'Apr', 'attendance': 79.8},
          {'month': 'May', 'attendance': 83.2},
          {'month': 'Jun', 'attendance': 87.1},
        ],
        'courseAttendance': [
          {'course': 'CSC101', 'attendance': 89.2},
          {'course': 'MAT201', 'attendance': 76.8},
          {'course': 'PHY301', 'attendance': 82.5},
          {'course': 'ENG102', 'attendance': 91.3},
          {'course': 'CHE201', 'attendance': 74.6},
        ],
        'attendanceByMethod': {
          'facial_recognition': 65.2,
          'geofence': 34.8,
        },
      };
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading analytics: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('System Analytics'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
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
                  // Overview Cards
                  Text(
                    'System Overview',
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
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildOverviewCard(
                        'Total Students',
                        '${_analyticsData['totalStudents']}',
                        Icons.group,
                        Colors.blue,
                      ),
                      _buildOverviewCard(
                        'Total Lecturers',
                        '${_analyticsData['totalLecturers']}',
                        Icons.person_outline,
                        Colors.green,
                      ),
                      _buildOverviewCard(
                        'Total Courses',
                        '${_analyticsData['totalCourses']}',
                        Icons.book,
                        Colors.orange,
                      ),
                      _buildOverviewCard(
                        'Avg. Attendance',
                        '${_analyticsData['averageAttendance']}%',
                        Icons.trending_up,
                        Colors.purple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  // Monthly Attendance Chart
                  Text(
                    'Monthly Attendance Trend',
                    style: AppTheme.headingStyle.copyWith(
                      color: AppTheme.primaryColor,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 250,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text('${value.toInt()}%');
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                                if (value.toInt() < months.length) {
                                  return Text(months[value.toInt()]);
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: (_analyticsData['monthlyAttendance'] as List)
                                .asMap()
                                .entries
                                .map((entry) => FlSpot(
                                      entry.key.toDouble(),
                                      entry.value['attendance'].toDouble(),
                                    ))
                                .toList(),
                            isCurved: true,
                            color: AppTheme.primaryColor,
                            barWidth: 3,
                            dotData: FlDotData(show: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Attendance by Method Pie Chart
                  Text(
                    'Attendance Verification Methods',
                    style: AppTheme.headingStyle.copyWith(
                      color: AppTheme.primaryColor,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  value: _analyticsData['attendanceByMethod']['facial_recognition'],
                                  title: '${_analyticsData['attendanceByMethod']['facial_recognition']}%',
                                  color: AppTheme.primaryColor,
                                  radius: 60,
                                ),
                                PieChartSectionData(
                                  value: _analyticsData['attendanceByMethod']['geofence'],
                                  title: '${_analyticsData['attendanceByMethod']['geofence']}%',
                                  color: Colors.orange,
                                  radius: 60,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLegendItem('Facial Recognition', AppTheme.primaryColor),
                            const SizedBox(height: 8),
                            _buildLegendItem('Geofence', Colors.orange),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Top Performing Courses
                  Text(
                    'Course Attendance Performance',
                    style: AppTheme.headingStyle.copyWith(
                      color: AppTheme.primaryColor,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: (_analyticsData['courseAttendance'] as List)
                          .map((course) => _buildCourseAttendanceItem(
                                course['course'],
                                course['attendance'].toDouble(),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.headingStyle.copyWith(
              color: color,
              fontSize: 20,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTheme.bodyStyle.copyWith(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTheme.bodyStyle.copyWith(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCourseAttendanceItem(String course, double attendance) {
    final color = attendance >= 80 ? Colors.green : attendance >= 60 ? Colors.orange : Colors.red;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              course,
              style: AppTheme.bodyStyle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: LinearProgressIndicator(
              value: attendance / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${attendance.toStringAsFixed(1)}%',
            style: AppTheme.bodyStyle.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
