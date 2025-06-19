import 'package:flutter/material.dart';
import 'package:smartcheck/models/course.dart';
import 'package:smartcheck/utils/app_theme.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  final Course course;

  const AttendanceHistoryScreen({
    super.key,
    required this.course,
  });

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _currentAttendance = [];
  List<Map<String, dynamic>> _overallAttendance = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAttendanceData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Simulated data loading
  Future<void> _loadAttendanceData() async {
    // TODO: Replace with actual API call to fetch attendance history
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _currentAttendance = [
          {
            'date': 'Thursday 26 May 2025',
            'sessions': [
              {'time': '11:00', 'course': 'Human Computer Inter', 'code': 'CEF 472', 'status': 'P'},
              {'time': '1:00', 'course': 'Human Computer Inter', 'code': 'CEF 472', 'status': 'A'},
            ],
          },
          {
            'date': 'Friday 29 May 2025',
            'sessions': [
              {'time': '11:00', 'course': 'Human Computer Inter', 'code': 'CEF 472', 'status': 'P'},
              {'time': '1:00', 'course': 'Human Computer Inter', 'code': 'CEF 472', 'status': 'A'},
            ],
          },
        ];
        
        _overallAttendance = [
          {'course': 'Human Computer Interface', 'code': 'CEF 472', 'percentage': 98.3, 'present': 12, 'total': 20},
          {'course': 'Human Computer Interface', 'code': 'CEF 472', 'percentage': 85.0, 'present': 17, 'total': 20},
          {'course': 'Human Computer Interface', 'code': 'CEF 472', 'percentage': 90.0, 'present': 18, 'total': 20},
          {'course': 'Human Computer Interface', 'code': 'CEF 472', 'percentage': 75.0, 'present': 15, 'total': 20},
        ];
        
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Current Attendance'),
            Tab(text: 'Overall Attendance'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCurrentAttendanceTab(),
                _buildOverallAttendanceTab(),
              ],
            ),
    );
  }

  Widget _buildCurrentAttendanceTab() {
    return RefreshIndicator(
      onRefresh: _loadAttendanceData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _currentAttendance.length,
        itemBuilder: (context, index) {
          final dayData = _currentAttendance[index];
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
                  Text(
                    dayData['date'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...dayData['sessions'].map<Widget>((session) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              session['time'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session['course'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  session['code'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: session['status'] == 'P' 
                                  ? AppTheme.successColor 
                                  : AppTheme.errorColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                session['status'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverallAttendanceTab() {
    return RefreshIndicator(
      onRefresh: _loadAttendanceData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _overallAttendance.length,
        itemBuilder: (context, index) {
          final attendance = _overallAttendance[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          attendance['course'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          attendance['code'],
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${attendance['present']}/${attendance['total']}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '${attendance['percentage']}%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: attendance['percentage'] >= 75 
                              ? AppTheme.successColor 
                              : AppTheme.errorColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: attendance['percentage'] >= 75 
                              ? AppTheme.successColor.withOpacity(0.1)
                              : AppTheme.errorColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          attendance['percentage'] >= 75 
                              ? Icons.check_circle 
                              : Icons.warning,
                          color: attendance['percentage'] >= 75 
                              ? AppTheme.successColor 
                              : AppTheme.errorColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
