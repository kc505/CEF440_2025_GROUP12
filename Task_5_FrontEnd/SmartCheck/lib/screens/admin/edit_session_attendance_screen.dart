import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../models/course.dart';
import '../../models/session.dart';
import '../../models/student.dart';

class EditSessionAttendanceScreen extends StatefulWidget {
  final Course course;
  
  const EditSessionAttendanceScreen({Key? key, required this.course}) : super(key: key);

  @override
  State<EditSessionAttendanceScreen> createState() => _EditSessionAttendanceScreenState();
}

class _EditSessionAttendanceScreenState extends State<EditSessionAttendanceScreen> {
  List<Session> _sessions = [];
  Session? _selectedSession;
  List<StudentAttendance> _attendanceList = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Implement API call to fetch sessions for this course
      // final response = await http.get(
      //   Uri.parse('${ApiConstants.baseUrl}/admin/courses/${widget.course.id}/sessions'),
      //   headers: {'Authorization': 'Bearer ${authProvider.token}'},
      // );
      
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      _sessions = [
        Session(
          id: '1',
          courseId: widget.course.id,
          title: 'Introduction to Programming',
          date: DateTime.now().subtract(const Duration(days: 14)),
          startTime: '09:00',
          endTime: '11:00',
          venue: 'Computer Lab A',
          attendanceCount: 42,
          totalStudents: 45,
        ),
        Session(
          id: '2',
          courseId: widget.course.id,
          title: 'Variables and Data Types',
          date: DateTime.now().subtract(const Duration(days: 7)),
          startTime: '09:00',
          endTime: '11:00',
          venue: 'Computer Lab A',
          attendanceCount: 38,
          totalStudents: 45,
        ),
        Session(
          id: '3',
          courseId: widget.course.id,
          title: 'Control Structures',
          date: DateTime.now().subtract(const Duration(days: 3)),
          startTime: '09:00',
          endTime: '11:00',
          venue: 'Computer Lab A',
          attendanceCount: 40,
          totalStudents: 45,
        ),
      ];
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading sessions: ${e.toString()}'),
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

  Future<void> _loadSessionAttendance(String sessionId) async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Implement API call to fetch attendance for specific session
      // final response = await http.get(
      //   Uri.parse('${ApiConstants.baseUrl}/admin/sessions/$sessionId/attendance'),
      //   headers: {'Authorization': 'Bearer ${authProvider.token}'},
      // );
      
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      _attendanceList = [
        StudentAttendance(
          studentId: '1',
          studentName: 'Alice Johnson',
          matricule: 'CSC/2021/001',
          isPresent: true,
          checkInTime: '09:15',
          verificationMethod: 'Facial Recognition',
        ),
        StudentAttendance(
          studentId: '2',
          studentName: 'Bob Smith',
          matricule: 'CSC/2021/002',
          isPresent: false,
          checkInTime: null,
          verificationMethod: null,
        ),
        StudentAttendance(
          studentId: '3',
          studentName: 'Carol Davis',
          matricule: 'CSC/2021/003',
          isPresent: true,
          checkInTime: '09:05',
          verificationMethod: 'Geofence',
        ),
        StudentAttendance(
          studentId: '4',
          studentName: 'David Wilson',
          matricule: 'CSC/2021/004',
          isPresent: true,
          checkInTime: '09:20',
          verificationMethod: 'Facial Recognition',
        ),
        StudentAttendance(
          studentId: '5',
          studentName: 'Eva Brown',
          matricule: 'CSC/2021/005',
          isPresent: false,
          checkInTime: null,
          verificationMethod: null,
        ),
      ];
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading attendance: ${e.toString()}'),
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

  Future<void> _saveAttendance() async {
    setState(() => _isSaving = true);
    
    try {
      // TODO: Implement API call to save attendance changes
      // final response = await http.put(
      //   Uri.parse('${ApiConstants.baseUrl}/admin/sessions/${_selectedSession!.id}/attendance'),
      //   headers: {
      //     'Content-Type': 'application/json',
      //     'Authorization': 'Bearer ${authProvider.token}',
      //   },
      //   body: jsonEncode({
      //     'attendance': _attendanceList.map((a) => a.toJson()).toList(),
      //   }),
      // );
      
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving attendance: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Edit ${widget.course.code} Attendance'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_selectedSession != null && _attendanceList.isNotEmpty)
            IconButton(
              icon: _isSaving 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save),
              onPressed: _isSaving ? null : _saveAttendance,
            ),
        ],
      ),
      body: Column(
        children: [
          // Course Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryColor.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
<<<<<<< HEAD
                  widget.course.title,
=======
                  widget.course.title ?? 'Untitled',
>>>>>>> ashley
                  style: AppTheme.headingStyle.copyWith(
                    color: AppTheme.primaryColor,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select a session to edit attendance records',
                  style: AppTheme.bodyStyle.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          
          // Session Selection
          if (_isLoading && _sessions.isEmpty)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_sessions.isEmpty)
            const Expanded(
              child: Center(
                child: Text('No sessions found for this course'),
              ),
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(16),
              child: DropdownButtonFormField<Session>(
                decoration: const InputDecoration(
                  labelText: 'Select Session',
                  border: OutlineInputBorder(),
                ),
                value: _selectedSession,
                items: _sessions.map((session) {
                  return DropdownMenuItem<Session>(
                    value: session,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          session.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${session.date.day}/${session.date.month}/${session.date.year} - ${session.startTime}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (Session? session) {
                  setState(() {
                    _selectedSession = session;
                    _attendanceList.clear();
                  });
                  if (session != null) {
                    _loadSessionAttendance(session.id);
                  }
                },
              ),
            ),
            
            // Attendance List
            if (_selectedSession != null) ...[
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _attendanceList.isEmpty
                        ? const Center(
                            child: Text('No attendance records found'),
                          )
                        : Column(
                            children: [
                              // Summary
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildSummaryItem(
                                      'Present',
                                      '${_attendanceList.where((a) => a.isPresent).length}',
                                      Colors.green,
                                    ),
                                    _buildSummaryItem(
                                      'Absent',
                                      '${_attendanceList.where((a) => !a.isPresent).length}',
                                      Colors.red,
                                    ),
                                    _buildSummaryItem(
                                      'Total',
                                      '${_attendanceList.length}',
                                      Colors.blue,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Student List
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: _attendanceList.length,
                                  itemBuilder: (context, index) {
                                    final attendance = _attendanceList[index];
                                    return _buildAttendanceCard(attendance, index);
                                  },
                                ),
                              ),
                            ],
                          ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceCard(StudentAttendance attendance, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Student Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attendance.studentName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    attendance.matricule,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  if (attendance.isPresent && attendance.checkInTime != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Check-in: ${attendance.checkInTime} (${attendance.verificationMethod})',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Attendance Toggle
            Switch(
              value: attendance.isPresent,
              onChanged: (bool value) {
                setState(() {
                  _attendanceList[index] = attendance.copyWith(
                    isPresent: value,
                    checkInTime: value ? '09:00' : null,
                    verificationMethod: value ? 'Manual Edit' : null,
                  );
                });
              },
              activeColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

// Supporting models
class Session {
  final String id;
  final String courseId;
  final String title;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String venue;
  final int attendanceCount;
  final int totalStudents;

  Session({
    required this.id,
    required this.courseId,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.venue,
    required this.attendanceCount,
    required this.totalStudents,
  });
}

class StudentAttendance {
  final String studentId;
  final String studentName;
  final String matricule;
  final bool isPresent;
  final String? checkInTime;
  final String? verificationMethod;

  StudentAttendance({
    required this.studentId,
    required this.studentName,
    required this.matricule,
    required this.isPresent,
    this.checkInTime,
    this.verificationMethod,
  });

  StudentAttendance copyWith({
    String? studentId,
    String? studentName,
    String? matricule,
    bool? isPresent,
    String? checkInTime,
    String? verificationMethod,
  }) {
    return StudentAttendance(
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      matricule: matricule ?? this.matricule,
      isPresent: isPresent ?? this.isPresent,
      checkInTime: checkInTime ?? this.checkInTime,
      verificationMethod: verificationMethod ?? this.verificationMethod,
    );
  }
}
