import 'package:flutter/material.dart';
import 'package:smartcheck/models/course.dart';
import 'package:smartcheck/utils/app_theme.dart';

class AttendanceAnalyticsScreen extends StatefulWidget {
  final Course course;

  const AttendanceAnalyticsScreen({
    Key? key,
    required this.course,
  }) : super(key: key);

  @override
  State<AttendanceAnalyticsScreen> createState() => _AttendanceAnalyticsScreenState();
}

class _AttendanceAnalyticsScreenState extends State<AttendanceAnalyticsScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _analyticsData = {};
  String _selectedPeriod = 'Last 30 Days';

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  // Simulated data loading
  Future<void> _loadAnalyticsData() async {
    // TODO: Replace with actual API call to fetch analytics data
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _analyticsData = {
          'overallAttendance': 82.5,
          'trend': 'increasing',
          'trendPercentage': 5.2,
          'totalSessions': 15,
          'averageStudentsPerSession': 38,
          'monthlyData': [
            {'month': 'Jan', 'attendance': 78},
            {'month': 'Feb', 'attendance': 82},
            {'month': 'Mar', 'attendance': 85},
            {'month': 'Apr', 'attendance': 80},
            {'month': 'May', 'attendance': 83},
          ],
          'weeklyData': [
            {'week': 'Week 1', 'attendance': 85},
            {'week': 'Week 2', 'attendance': 78},
            {'week': 'Week 3', 'attendance': 92},
            {'week': 'Week 4', 'attendance': 88},
          ],
          'timeSlotData': [
            {'time': '8:00 AM', 'attendance': 65},
            {'time': '10:00 AM', 'attendance': 85},
            {'time': '2:00 PM', 'attendance': 78},
            {'time': '4:00 PM', 'attendance': 70},
          ],
          'topPerformers': [
            {'name': 'Emily Williams', 'rate': 100.0},
            {'name': 'John Doe', 'rate': 96.7},
            {'name': 'Jane Smith', 'rate': 93.3},
            {'name': 'Michael Johnson', 'rate': 90.0},
            {'name': 'Sarah Davis', 'rate': 86.7},
          ],
          'lowPerformers': [
            {'name': 'Robert Wilson', 'rate': 45.0},
            {'name': 'Lisa Anderson', 'rate': 52.3},
            {'name': 'James Taylor', 'rate': 58.7},
            {'name': 'Maria Garcia', 'rate': 63.3},
            {'name': 'David Brown', 'rate': 68.0},
          ],
        };
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Analytics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
              _loadAnalyticsData();
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'Last 7 Days',
                child: Text('Last 7 Days'),
              ),
              const PopupMenuItem<String>(
                value: 'Last 30 Days',
                child: Text('Last 30 Days'),
              ),
              const PopupMenuItem<String>(
                value: 'Last 3 Months',
                child: Text('Last 3 Months'),
              ),
              const PopupMenuItem<String>(
                value: 'This Semester',
                child: Text('This Semester'),
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
                    // Course info
                    Text(
                      '${widget.course.code}: ${widget.course.name}',
                      style: AppTheme.headingStyle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Analytics for $_selectedPeriod',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Overall statistics
                    _buildOverallStats(),
                    const SizedBox(height: 24),
                    
                    // Monthly trend chart
                    const Text(
                      'Monthly Attendance Trend',
                      style: AppTheme.subheadingStyle,
                    ),
                    const SizedBox(height: 16),
                    _buildMonthlyChart(),
                    const SizedBox(height: 24),
                    
                    // Weekly breakdown
                    const Text(
                      'Weekly Breakdown',
                      style: AppTheme.subheadingStyle,
                    ),
                    const SizedBox(height: 16),
                    _buildWeeklyChart(),
                    const SizedBox(height: 24),
                    
                    // Time slot analysis
                    const Text(
                      'Attendance by Time Slot',
                      style: AppTheme.subheadingStyle,
                    ),
                    const SizedBox(height: 16),
                    _buildTimeSlotChart(),
                    const SizedBox(height: 24),
                    
                    // Top and low performers
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Top Performers',
                                style: AppTheme.subheadingStyle,
                              ),
                              const SizedBox(height: 16),
                              _buildPerformersList(true),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Needs Attention',
                                style: AppTheme.subheadingStyle,
                              ),
                              const SizedBox(height: 16),
                              _buildPerformersList(false),
                            ],
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

  Widget _buildOverallStats() {
    final isIncreasing = _analyticsData['trend'] == 'increasing';
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${_analyticsData['overallAttendance']}%',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isIncreasing ? Icons.trending_up : Icons.trending_down,
                  color: isIncreasing ? AppTheme.successColor : AppTheme.errorColor,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_analyticsData['trendPercentage']}% ${isIncreasing ? 'increase' : 'decrease'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isIncreasing ? AppTheme.successColor : AppTheme.errorColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('Sessions', _analyticsData['totalSessions'].toString()),
                _buildStatItem('Avg. Students', _analyticsData['averageStudentsPerSession'].toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _analyticsData['monthlyData'].map<Widget>((monthData) {
                return _buildChartBar(
                  monthData['month'],
                  monthData['attendance'] / 100.0,
                  AppTheme.primaryColor,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _analyticsData['weeklyData'].map<Widget>((weekData) {
                return _buildChartBar(
                  weekData['week'],
                  weekData['attendance'] / 100.0,
                  AppTheme.accentColor,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _analyticsData['timeSlotData'].map<Widget>((timeData) {
                return _buildChartBar(
                  timeData['time'],
                  timeData['attendance'] / 100.0,
                  AppTheme.secondaryColor,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildChartBar(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          '${(value * 100).toInt()}%',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 120 * value,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPerformersList(bool isTopPerformers) {
    final performers = isTopPerformers 
        ? _analyticsData['topPerformers'] 
        : _analyticsData['lowPerformers'];
    final color = isTopPerformers ? AppTheme.successColor : AppTheme.errorColor;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: performers.map<Widget>((performer) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: color.withOpacity(0.1),
                    child: Text(
                      performer['name'].substring(0, 2).toUpperCase(),
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          performer['name'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${performer['rate']}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.bold,
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
