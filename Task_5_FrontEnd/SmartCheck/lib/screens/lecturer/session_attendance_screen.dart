import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smartcheck/models/course.dart';
import 'package:smartcheck/models/session.dart';
import 'package:smartcheck/models/student.dart' hide StudentAttendance;
import 'package:smartcheck/utils/app_theme.dart';
import 'package:smartcheck/widgets/app_logo.dart';
import 'package:intl/intl.dart';

class SessionAttendanceScreen extends StatefulWidget {
  final Course course;
  final Session session;

  const SessionAttendanceScreen({
    super.key,
    required this.course,
    required this.session,
  });

  @override
  State<SessionAttendanceScreen> createState() => _SessionAttendanceScreenState();
}

class _SessionAttendanceScreenState extends State<SessionAttendanceScreen> {
  bool _isLoading = true;
  bool _isSessionActive = true;
  List<StudentAttendance> _studentAttendances = [];
  Timer? _refreshTimer;
  int _presentCount = 0;
  int _absentCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStudentAttendances();
    _startRealTimeUpdates();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startRealTimeUpdates() {
    // Refresh attendance data every 5 seconds for real-time updates
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_isSessionActive) {
        _loadStudentAttendances();
      }
    });
  }

  Future<void> _loadStudentAttendances() async {
    try {
      // TODO: Replace with actual API call to get real-time attendance data
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock student attendance data
      List<StudentAttendance> attendances = [
        StudentAttendance(
          studentId: '1',
          studentName: 'John Doe',
          matricule: 'STU001',
          isPresent: true,
          checkInTime: '10:05 AM',
          verificationMethod: 'Face Recognition + Geofence',
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        StudentAttendance(
          studentId: '2',
          studentName: 'Jane Smith',
          matricule: 'STU002',
          isPresent: true,
          checkInTime: '10:07 AM',
          verificationMethod: 'Face Recognition + Geofence',
          timestamp: DateTime.now().subtract(const Duration(minutes: 13)),
        ),
        StudentAttendance(
          studentId: '3',
          studentName: 'Michael Johnson',
          matricule: 'STU003',
          isPresent: false,
          checkInTime: null,
          verificationMethod: null,
          timestamp: null,
        ),
        StudentAttendance(
          studentId: '4',
          studentName: 'Emily Williams',
          matricule: 'STU004',
          isPresent: true,
          checkInTime: '10:12 AM',
          verificationMethod: 'Face Recognition + Geofence',
          timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        ),
        StudentAttendance(
          studentId: '5',
          studentName: 'David Brown',
          matricule: 'STU005',
          isPresent: false,
          checkInTime: null,
          verificationMethod: null,
          timestamp: null,
        ),
      ];

      if (mounted) {
        setState(() {
          _studentAttendances = attendances;
          _presentCount = attendances.where((a) => a.isPresent).length;
          _absentCount = attendances.where((a) => !a.isPresent).length;
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
            content: Text('Error loading attendance: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _toggleStudentAttendance(String studentId, bool isPresent) {
    setState(() {
      int index = _studentAttendances.indexWhere((a) => a.studentId == studentId);
      if (index != -1) {
        _studentAttendances[index] = _studentAttendances[index].copyWith(
          isPresent: isPresent,
          checkInTime: isPresent ? DateFormat('h:mm a').format(DateTime.now()) : null,
          verificationMethod: isPresent ? 'Manual Entry by Lecturer' : null,
          timestamp: isPresent ? DateTime.now() : null,
        );
        _presentCount = _studentAttendances.where((a) => a.isPresent).length;
        _absentCount = _studentAttendances.where((a) => !a.isPresent).length;
      }
    });

    // TODO: Send update to backend API
    _saveAttendanceUpdate(studentId, isPresent);
  }

  Future<void> _saveAttendanceUpdate(String studentId, bool isPresent) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      debugPrint('Attendance updated for student $studentId: $isPresent');
    } catch (e) {
      debugPrint('Error saving attendance update: $e');
    }
  }

  void _endSession() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('End Session'),
          content: Text(
            'Are you sure you want to end this session?\n\n'
            'Present: $_presentCount students\n'
            'Absent: $_absentCount students\n\n'
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _finalizeSession();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
              ),
              child: const Text('End Session'),
            ),
          ],
        );
      },
    );
  }

  void _finalizeSession() {
    setState(() {
      _isSessionActive = false;
    });
    _refreshTimer?.cancel();

    // TODO: Send final attendance data to backend
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Session ended. Final attendance: $_presentCount/$_absentCount'),
        backgroundColor: AppTheme.successColor,
      ),
    );

    // Navigate back after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const AppLogo(height: 28),
            const SizedBox(width: 8),
            Text('${widget.course.code} - Attendance'),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isSessionActive)
            TextButton(
              onPressed: _endSession,
              child: const Text(
                'End Session',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Session info header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.session.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('EEEE, MMMM d, yyyy').format(widget.session.date)} at ${widget.session.startTime} - ${widget.session.endTime}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      Text(
                        'Venue: ${widget.session.venue}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _isSessionActive ? AppTheme.successColor : AppTheme.errorColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _isSessionActive ? 'ACTIVE' : 'ENDED',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (_isSessionActive)
                            const Text(
                              '🔄 Real-time updates',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.successColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Attendance statistics
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Present',
                          _presentCount.toString(),
                          Icons.check_circle,
                          AppTheme.successColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Absent',
                          _absentCount.toString(),
                          Icons.cancel,
                          AppTheme.errorColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Total',
                          _studentAttendances.length.toString(),
                          Icons.people,
                          AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Student attendance list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadStudentAttendances,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _studentAttendances.length,
                      itemBuilder: (context, index) {
                        final attendance = _studentAttendances[index];
                        return _buildStudentAttendanceCard(attendance);
                      },
                    ),
                  ),
                ),

                // Session controls
                if (_isSessionActive)
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _endSession,
                            icon: const Icon(Icons.stop),
                            label: const Text('End Session'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.errorColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _loadStudentAttendances,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStudentAttendanceCard(StudentAttendance attendance) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: attendance.isPresent 
              ? AppTheme.successColor.withOpacity(0.3)
              : AppTheme.errorColor.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: attendance.isPresent 
                      ? AppTheme.successColor 
                      : AppTheme.errorColor,
                  child: Text(
                    attendance.studentName.split(' ').map((n) => n[0]).take(2).join(),
                    style: const TextStyle(
                      color: Colors.white,
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
                        attendance.studentName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ID: ${attendance.matricule}',
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
                    color: attendance.isPresent 
                        ? AppTheme.successColor 
                        : AppTheme.errorColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    attendance.isPresent ? 'PRESENT' : 'ABSENT',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            if (attendance.isPresent) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: AppTheme.successColor),
                        const SizedBox(width: 4),
                        Text(
                          'Check-in: ${attendance.checkInTime}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.successColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.verified, size: 16, color: AppTheme.successColor),
                        const SizedBox(width: 4),
                        Text(
                          'Method: ${attendance.verificationMethod}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.successColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: attendance.isPresent 
                        ? null 
                        : () => _toggleStudentAttendance(attendance.studentId, true),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Mark Present'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: !attendance.isPresent 
                        ? null 
                        : () => _toggleStudentAttendance(attendance.studentId, false),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Mark Absent'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
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
}
