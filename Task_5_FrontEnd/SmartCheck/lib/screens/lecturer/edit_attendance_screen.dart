import 'package:flutter/material.dart';
import 'package:smartcheck/models/course.dart';
import 'package:smartcheck/utils/app_theme.dart';
import 'package:smartcheck/widgets/custom_button.dart';

class EditAttendanceScreen extends StatefulWidget {
  final Course course;
  final Map<String, dynamic> sessionDetails;
  final List<Map<String, dynamic>> recognizedStudents;

  const EditAttendanceScreen({
    super.key,
    required this.course,
    required this.sessionDetails,
    required this.recognizedStudents,
  });

  @override
  State<EditAttendanceScreen> createState() => _EditAttendanceScreenState();
}

class _EditAttendanceScreenState extends State<EditAttendanceScreen> {
  List<Map<String, dynamic>> _allStudents = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadAllStudents();
  }

  Future<void> _loadAllStudents() async {
    // TODO: Replace with actual API call to fetch all enrolled students
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        // Simulate all enrolled students
        _allStudents = [
          {'id': '1', 'name': 'John Doe', 'studentId': 'ST001', 'isPresent': true},
          {'id': '2', 'name': 'Jane Smith', 'studentId': 'ST002', 'isPresent': true},
          {'id': '3', 'name': 'Michael Johnson', 'studentId': 'ST003', 'isPresent': true},
          {'id': '4', 'name': 'Emily Williams', 'studentId': 'ST004', 'isPresent': true},
          {'id': '5', 'name': 'David Brown', 'studentId': 'ST005', 'isPresent': true},
          {'id': '6', 'name': 'Sarah Davis', 'studentId': 'ST006', 'isPresent': false},
          {'id': '7', 'name': 'Robert Wilson', 'studentId': 'ST007', 'isPresent': false},
          {'id': '8', 'name': 'Lisa Anderson', 'studentId': 'ST008', 'isPresent': false},
          {'id': '9', 'name': 'James Taylor', 'studentId': 'ST009', 'isPresent': false},
          {'id': '10', 'name': 'Maria Garcia', 'studentId': 'ST010', 'isPresent': false},
        ];
        
        // Mark recognized students as present
        for (var recognizedStudent in widget.recognizedStudents) {
          final index = _allStudents.indexWhere((s) => s['id'] == recognizedStudent['id']);
          if (index != -1) {
            _allStudents[index]['isPresent'] = true;
          }
        }
        
        _isLoading = false;
      });
    }
  }

  void _toggleAttendance(int index) {
    setState(() {
      _allStudents[index]['isPresent'] = !_allStudents[index]['isPresent'];
    });
  }

  Future<void> _saveAttendance() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // TODO: Implement actual API call to save attendance
      // This would include:
      // - Session ID
      // - List of present students
      // - List of absent students
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance saved successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final presentCount = _allStudents.where((s) => s['isPresent']).length;
    final totalCount = _allStudents.length;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Attendance'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                // Session info and statistics
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.course.code}: ${widget.course.name}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.sessionDetails['date']} at ${widget.sessionDetails['time']}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.successColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Present: $presentCount',
                              style: const TextStyle(
                                color: AppTheme.successColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Absent: ${totalCount - presentCount}',
                              style: const TextStyle(
                                color: AppTheme.errorColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Rate: ${((presentCount / totalCount) * 100).toInt()}%',
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Students list
                Expanded(
                  child: ListView.builder(
                    itemCount: _allStudents.length,
                    itemBuilder: (context, index) {
                      final student = _allStudents[index];
                      final isPresent = student['isPresent'];
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isPresent 
                                ? AppTheme.successColor 
                                : AppTheme.errorColor,
                            child: Text(
                              student['name'].substring(0, 2).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            student['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Student ID: ${student['studentId']}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                          trailing: Switch(
                            value: isPresent,
                            onChanged: (value) => _toggleAttendance(index),
                            activeColor: AppTheme.successColor,
                          ),
                          onTap: () => _toggleAttendance(index),
                        ),
                      );
                    },
                  ),
                ),
                
                // Save button
                Container(
                  padding: const EdgeInsets.all(16),
                  child: CustomButton(
                    text: 'Save Attendance',
                    onPressed: _saveAttendance,
                    isLoading: _isSaving,
                  ),
                ),
              ],
            ),
    );
  }
}
