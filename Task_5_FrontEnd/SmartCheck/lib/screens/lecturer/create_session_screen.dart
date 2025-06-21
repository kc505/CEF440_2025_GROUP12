import 'package:flutter/material.dart';
import 'package:smartcheck/models/course.dart';
import 'package:smartcheck/models/session.dart';
import 'package:smartcheck/services/notification_service.dart';
import 'package:smartcheck/screens/lecturer/session_attendance_screen.dart';
import 'package:smartcheck/utils/app_theme.dart';
import 'package:smartcheck/widgets/custom_button.dart';
import 'package:smartcheck/widgets/custom_text_field.dart';
import 'package:intl/intl.dart';

class CreateSessionScreen extends StatefulWidget {
  final Course course;

  const CreateSessionScreen({
    super.key,
    required this.course,
  });

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _venueController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedStartTime = TimeOfDay.now();
  TimeOfDay _selectedEndTime = TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: TimeOfDay.now().minute);
  SessionStatus _sessionStatus = SessionStatus.draft;
  bool _isLoading = false;
  bool _sendNotification = true;

  @override
  void initState() {
    super.initState();
    _titleController.text = '${widget.course.code} - Lecture';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime,
    );
    if (picked != null && picked != _selectedStartTime) {
      setState(() {
        _selectedStartTime = picked;
        // Auto-adjust end time to be 1 hour after start time
        _selectedEndTime = TimeOfDay(
          hour: (picked.hour + 1) % 24,
          minute: picked.minute,
        );
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime,
    );
    if (picked != null && picked != _selectedEndTime) {
      setState(() {
        _selectedEndTime = picked;
      });
    }
  }

  Future<void> _createSession() async {
    if (_formKey.currentState!.validate()) {
      // Validate time logic
      final startMinutes = _selectedStartTime.hour * 60 + _selectedStartTime.minute;
      final endMinutes = _selectedEndTime.hour * 60 + _selectedEndTime.minute;
      
      if (endMinutes <= startMinutes) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End time must be after start time'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // At the beginning of _createSession method, add:
        final enrolledStudents = widget.course.enrolledStudents ?? [];

        // Create session object
        final session = Session(
          id: 'session_${DateTime.now().millisecondsSinceEpoch}',
          courseId: widget.course.id,
          courseName: widget.course.name,
          courseCode: widget.course.code,
          lecturerId: 'lecturer_1', // TODO: Get from auth provider
          lecturerName: 'Dr. Jane Smith', // TODO: Get from auth provider
          title: _titleController.text.trim(),
          date: _selectedDate,
          startTime: _selectedStartTime.format(context),
          endTime: _selectedEndTime.format(context),
          venue: _venueController.text.trim(),
          status: _sessionStatus,
          attendanceCount: 0,
          totalStudents: enrolledStudents.length,
          createdAt: DateTime.now(),
          enrolledStudents: enrolledStudents,
          geofenceData: {
            'latitude': 4.1536, // TODO: Get actual venue coordinates
            'longitude': 9.2840,
            'radius': 50.0, // 50 meters radius
            'altitude': 100.0, // Approximate altitude
          },
        );

        // TODO: Save session to database
        await Future.delayed(const Duration(seconds: 2));
        
        // Send notification to students if session is open and notification is enabled
        if (_sessionStatus == SessionStatus.open && _sendNotification) {
          final notificationSent = await NotificationService().sendSessionCreatedNotification(
            sessionId: session.id,
            courseCode: session.courseCode,
            courseName: session.courseName,
            venue: session.venue,
            date: session.date,
            startTime: session.startTime,
            endTime: session.endTime,
            studentIds: enrolledStudents,
          );

          if (notificationSent) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Session created and notifications sent to ${enrolledStudents.length} students!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            }
          }
        }
        
        if (mounted) {
          // Navigate to session attendance screen if session is open
          if (_sessionStatus == SessionStatus.open) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SessionAttendanceScreen(
                  course: widget.course,
                  sessionDetails: {
                    'id': session.id,
                    'title': session.title,
                    'date': DateFormat('EEEE, MMMM d, yyyy').format(session.date),
                    'time': '${session.startTime} - ${session.endTime}',
                    'venue': session.venue,
                    'status': session.status.displayName,
                  },
                ),
              ),
            );
          } else {
            // Just go back if session is saved as draft
            Navigator.pop(context, session);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating session: ${e.toString()}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Session'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course info header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.course.code}: ${widget.course.name}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Enrolled Students: ${widget.course.enrolledStudents?.length ?? 0}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Session title
                  CustomTextField(
                    label: 'Session Title',
                    controller: _titleController,
                    prefixIcon: const Icon(Icons.title),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter session title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Date picker
                  const Text(
                    'Session Date',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.dividerColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Time pickers
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Start Time',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => _selectStartTime(context),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppTheme.dividerColor),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      color: AppTheme.primaryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _selectedStartTime.format(context),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'End Time',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => _selectEndTime(context),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppTheme.dividerColor),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      color: AppTheme.primaryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _selectedEndTime.format(context),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Venue field
                  CustomTextField(
                    label: 'Venue',
                    controller: _venueController,
                    prefixIcon: const Icon(Icons.location_on),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter venue';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Session status
                  const Text(
                    'Session Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.dividerColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<SessionStatus>(
                        value: _sessionStatus,
                        isExpanded: true,
                        items: [
                          DropdownMenuItem(
                            value: SessionStatus.draft,
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.orange[600]),
                                const SizedBox(width: 8),
                                const Text('Draft - Save without opening'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: SessionStatus.open,
                            child: Row(
                              children: [
                                const Icon(Icons.play_circle, color: AppTheme.successColor),
                                const SizedBox(width: 8),
                                const Text('Open - Students can mark attendance'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (SessionStatus? value) {
                          if (value != null) {
                            setState(() {
                              _sessionStatus = value;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Status explanation
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _sessionStatus == SessionStatus.open 
                          ? AppTheme.successColor.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _sessionStatus == SessionStatus.open 
                            ? AppTheme.successColor.withOpacity(0.3)
                            : Colors.orange.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _sessionStatus == SessionStatus.open 
                              ? Icons.info_outline 
                              : Icons.warning_amber_outlined,
                          color: _sessionStatus == SessionStatus.open 
                              ? AppTheme.successColor 
                              : Colors.orange[600],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _sessionStatus == SessionStatus.open
                                ? 'Students will be notified and can immediately start marking attendance using facial recognition and geofencing.'
                                : 'Session will be saved as draft. Students cannot mark attendance until you change status to "Open".',
                            style: TextStyle(
                              fontSize: 12,
                              color: _sessionStatus == SessionStatus.open 
                                  ? AppTheme.successColor 
                                  : Colors.orange[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Notification toggle
                  if (_sessionStatus == SessionStatus.open) ...[
                    Row(
                      children: [
                        Checkbox(
                          value: _sendNotification,
                          onChanged: (bool? value) {
                            setState(() {
                              _sendNotification = value ?? true;
                            });
                          },
                        ),
                        const Expanded(
                          child: Text(
                            'Send notification to students when session is created',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // Create button
                  CustomButton(
                    text: _sessionStatus == SessionStatus.open 
                        ? 'Create & Open Session' 
                        : 'Save as Draft',
                    onPressed: _createSession,
                    isLoading: _isLoading,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Help text
                  const Text(
                    'Note: Only "Open" sessions allow students to mark attendance. You can change the status later from the session management screen.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
