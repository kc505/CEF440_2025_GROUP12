import 'package:flutter/material.dart';
import 'package:smartcheck/models/course.dart';
import 'package:smartcheck/utils/app_theme.dart';
import 'package:intl/intl.dart';

class AttendanceReportScreen extends StatefulWidget {
  final Course course;

  const AttendanceReportScreen({
    Key? key,
    required this.course,
  }) : super(key: key);

  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isLoading = false;
  bool _isGenerating = false;
  Map<String, dynamic> _reportData = {};

  @override
  void initState() {
    super.initState();
    _generateReport();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _generateReport();
    }
  }

  Future<void> _generateReport() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement actual API call to generate report
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() {
          _reportData = {
            'totalSessions': 15,
            'averageAttendance': 82.5,
            'totalStudents': 45,
            'presentDays': 556,
            'absentDays': 119,
            'sessionData': [
              {'date': 'May 15, 2025', 'present': 40, 'absent': 5, 'rate': 88.9},
              {'date': 'May 12, 2025', 'present': 38, 'absent': 7, 'rate': 84.4},
              {'date': 'May 8, 2025', 'present': 35, 'absent': 10, 'rate': 77.8},
              {'date': 'May 5, 2025', 'present': 42, 'absent': 3, 'rate': 93.3},
              {'date': 'May 1, 2025', 'present': 36, 'absent': 9, 'rate': 80.0},
            ],
            'studentData': [
              {'name': 'John Doe', 'present': 14, 'absent': 1, 'rate': 93.3},
              {'name': 'Jane Smith', 'present': 13, 'absent': 2, 'rate': 86.7},
              {'name': 'Michael Johnson', 'present': 12, 'absent': 3, 'rate': 80.0},
              {'name': 'Emily Williams', 'present': 15, 'absent': 0, 'rate': 100.0},
              {'name': 'David Brown', 'present': 11, 'absent': 4, 'rate': 73.3},
            ],
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _downloadReport() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      // TODO: Implement actual report generation and download
      // This would typically:
      // 1. Generate PDF/Excel report
      // 2. Save to device storage
      // 3. Show download confirmation
      await Future.delayed(const Duration(seconds: 3));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report downloaded successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Report'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _isGenerating ? null : _downloadReport,
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
                    const SizedBox(height: 24),
                    
                    // Date range selector
                    Card(
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
                              'Report Period',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: _selectDateRange,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppTheme.dividerColor),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.date_range, color: AppTheme.primaryColor),
                                    const SizedBox(width: 12),
                                    Text(
                                      '${DateFormat('MMM d, yyyy').format(_startDate)} - ${DateFormat('MMM d, yyyy').format(_endDate)}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const Spacer(),
                                    const Icon(Icons.arrow_drop_down),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Summary statistics
                    _buildSummaryCards(),
                    const SizedBox(height: 24),
                    
                    // Session-wise attendance
                    const Text(
                      'Session-wise Attendance',
                      style: AppTheme.subheadingStyle,
                    ),
                    const SizedBox(height: 16),
                    _buildSessionTable(),
                    const SizedBox(height: 24),
                    
                    // Student-wise attendance
                    const Text(
                      'Student-wise Attendance',
                      style: AppTheme.subheadingStyle,
                    ),
                    const SizedBox(height: 16),
                    _buildStudentTable(),
                    const SizedBox(height: 24),
                    
                    // Download button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isGenerating ? null : _downloadReport,
                        icon: _isGenerating 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.download),
                        label: Text(_isGenerating ? 'Generating...' : 'Download Report'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Sessions',
                _reportData['totalSessions'].toString(),
                Icons.calendar_today,
                AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Avg. Attendance',
                '${_reportData['averageAttendance']}%',
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
                'Total Students',
                _reportData['totalStudents'].toString(),
                Icons.people,
                AppTheme.accentColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Present Days',
                _reportData['presentDays'].toString(),
                Icons.check,
                AppTheme.successColor,
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

  Widget _buildSessionTable() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Table header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Expanded(flex: 2, child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(child: Text('Present', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(child: Text('Absent', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(child: Text('Rate', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            const SizedBox(height: 8),
            
            // Table rows
            ...(_reportData['sessionData'] as List).map((session) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text(session['date'])),
                    Expanded(child: Text(session['present'].toString())),
                    Expanded(child: Text(session['absent'].toString())),
                    Expanded(
                      child: Text(
                        '${session['rate'].toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: session['rate'] >= 80 
                              ? AppTheme.successColor 
                              : AppTheme.errorColor,
                          fontWeight: FontWeight.bold,
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
  }

  Widget _buildStudentTable() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Table header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Expanded(flex: 2, child: Text('Student', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(child: Text('Present', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(child: Text('Absent', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(child: Text('Rate', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            const SizedBox(height: 8),
            
            // Table rows
            ...(_reportData['studentData'] as List).map((student) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text(student['name'])),
                    Expanded(child: Text(student['present'].toString())),
                    Expanded(child: Text(student['absent'].toString())),
                    Expanded(
                      child: Text(
                        '${student['rate'].toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: student['rate'] >= 80 
                              ? AppTheme.successColor 
                              : AppTheme.errorColor,
                          fontWeight: FontWeight.bold,
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
  }
}
