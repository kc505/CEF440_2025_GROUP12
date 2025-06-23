import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/course.dart';
import '../../models/session.dart';
import '../../models/geofence_venue.dart';
import '../../providers/auth_provider.dart';
import '../../services/file_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/constants.dart';
import '../../utils/app_theme.dart';

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
  final _sessionNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  GeofenceVenue? _selectedVenue;
  List<GeofenceVenue> _venues = [];
  bool _isLoading = false;
  bool _requiresGeofence = true;
  bool _requiresFaceRecognition = true;
  bool _allowLateEntry = false;
  int _lateEntryMinutes = 15;

  @override
  void initState() {
    super.initState();
    _loadVenues();
    _durationController.text = '90'; // Default 90 minutes
  }

  @override
  void dispose() {
    _sessionNameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _loadVenues() async {
    try {
      setState(() => _isLoading = true);
      
      // Simulate loading venues from API
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock data - replace with actual API call
      _venues = [
        GeofenceVenue(
          id: '1',
          name: 'Main Lecture Hall',
          latitude: 37.7749,
          longitude: -122.4194,
          radius: 50.0,
          isActive: true, 
          description: '',
        ),
        GeofenceVenue(
          id: '2',
          name: 'Computer Lab A',
          latitude: 37.7849,
          longitude: -122.4094,
          radius: 30.0,
          isActive: true,
          description: '',
        ),
        GeofenceVenue(
          id: '3',
          name: 'Science Building Room 201',
          latitude: 37.7649,
          longitude: -122.4294,
          radius: 40.0,
          isActive: true,
          description: '',
        ),
      ];
      
      if (_venues.isNotEmpty) {
        _selectedVenue = _venues.first;
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load venues: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF2196F3),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF2196F3),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
        // Auto-calculate end time based on duration
        _calculateEndTime();
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF2196F3),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
        // Update duration based on time difference
        _updateDurationFromTimes();
      });
    }
  }

  void _calculateEndTime() {
    if (_startTime != null && _durationController.text.isNotEmpty) {
      final duration = int.tryParse(_durationController.text) ?? 0;
      if (duration > 0) {
        final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
        final endMinutes = startMinutes + duration;
        final endHour = (endMinutes ~/ 60) % 24;
        final endMinute = endMinutes % 60;
        
        setState(() {
          _endTime = TimeOfDay(hour: endHour, minute: endMinute);
        });
      }
    }
  }

  void _updateDurationFromTimes() {
    if (_startTime != null && _endTime != null) {
      final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
      final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
      final duration = endMinutes - startMinutes;
      
      if (duration > 0) {
        _durationController.text = duration.toString();
      }
    }
  }


  Future<void> _createSession() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      _showErrorSnackBar('Please select a date');
      return;
    }

    if (_startTime == null) {
      _showErrorSnackBar('Please select start time');
      return;
    }

    if (_endTime == null) {
      _showErrorSnackBar('Please select end time');
      return;
    }

    if (_requiresGeofence && _selectedVenue == null) {
      _showErrorSnackBar('Please select a venue for geofence');
      return;
    }

    try {
      setState(() => _isLoading = true);

      Provider.of<AuthProvider>(context, listen: false);
      
      // Combine date and time
      final startDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );

      final endDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      final session = Session(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  courseId: widget.course.id,
  courseCode: widget.course.code,
  title: _sessionNameController.text.trim(),
  date: startDateTime,
  startTime: DateFormat('HH:mm').format(startDateTime),
  endTime: DateFormat('HH:mm').format(endDateTime),
  venue: _selectedVenue?.name ?? 'TBD',
  status: SessionStatus.open,
  attendanceCount: 0,
  totalStudents: widget.course.enrolledStudents?.length ?? 0,
  enrolledStudents: widget.course.enrolledStudents ?? [],
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  courseName: '',
  lecturerId: '',
  lecturerName: '',
);


      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Show success message
      _showSuccessSnackBar('Session created successfully!');

      // Navigate back
      Navigator.of(context).pop(session);

    } catch (e) {
      _showErrorSnackBar('Failed to create session: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Session'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading && _venues.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course Info Card
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Course Information',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2196F3),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Course: ${widget.course.name}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              'Code: ${widget.course.code}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Session Details
                    Text(
                      'Session Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Session Name
                    CustomTextField(
                      controller: _sessionNameController,
                      label: 'Session Name',
                      hint: 'Enter session name',
                      prefixIcon: const Icon(Icons.class_),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter session name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Description (Optional)',
                      hint: 'Enter session description',
                      prefixIcon: const Icon(Icons.description),
                      validator: null,
                    ),
                    const SizedBox(height: 16),

                    // Date Selection
                    InkWell(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: const Color(0xFF2196F3)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    _selectedDate != null
                                        ? DateFormat('EEEE, MMMM d, y').format(_selectedDate!)
                                        : 'Select date',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _selectedDate != null ? Colors.black : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Time Selection Row
                    Row(
                      children: [
                        // Start Time
                        Expanded(
                          child: InkWell(
                            onTap: _selectStartTime,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time, color: const Color(0xFF2196F3)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Start Time',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        Text(
                                          _startTime != null
                                              ? _startTime!.format(context)
                                              : 'Select',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: _startTime != null ? Colors.black : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // End Time
                        Expanded(
                          child: InkWell(
                            onTap: _selectEndTime,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time_filled, color: const Color(0xFF2196F3)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'End Time',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        Text(
                                          _endTime != null
                                              ? _endTime!.format(context)
                                              : 'Select',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: _endTime != null ? Colors.black : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Duration
                    CustomTextField(
                      controller: _durationController,
                      label: 'Duration (minutes)',
                      hint: 'Enter duration in minutes',
                      prefixIcon: const Icon(Icons.timer),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter duration';
                        }
                        final duration = int.tryParse(value);
                        if (duration == null || duration <= 0) {
                          return 'Please enter valid duration';
                        }
                        if (duration > 480) { // 8 hours max
                          return 'Duration cannot exceed 8 hours';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Attendance Settings
                    Text(
                      'Attendance Settings',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Geofence Setting
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: const Text('Require Geofence'),
                              subtitle: const Text('Students must be within venue location'),
                              value: _requiresGeofence,
                              onChanged: (value) {
                                setState(() {
                                  _requiresGeofence = value;
                                });
                              },
                              activeColor: const Color(0xFF2196F3),
                            ),
                            if (_requiresGeofence) ...[
                              const Divider(),
                              DropdownButtonFormField<GeofenceVenue>(
                                value: _selectedVenue,
                                decoration: const InputDecoration(
                                  labelText: 'Select Venue',
                                  prefixIcon: Icon(Icons.location_on),
                                  border: OutlineInputBorder(),
                                ),
                                items: _venues.map((venue) {
                                  return DropdownMenuItem<GeofenceVenue>(
                                    value: venue,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(venue.name),
                                        Text(
                                          'Radius: ${venue.radius}m',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (venue) {
                                  setState(() {
                                    _selectedVenue = venue;
                                  });
                                },
                                validator: _requiresGeofence
                                    ? (value) {
                                        if (value == null) {
                                          return 'Please select a venue';
                                        }
                                        return null;
                                      }
                                    : null,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Face Recognition Setting
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SwitchListTile(
                          title: const Text('Require Face Recognition'),
                          subtitle: const Text('Students must verify identity with face scan'),
                          value: _requiresFaceRecognition,
                          onChanged: (value) {
                            setState(() {
                              _requiresFaceRecognition = value;
                            });
                          },
                          activeColor: const Color(0xFF2196F3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Late Entry Setting
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: const Text('Allow Late Entry'),
                              subtitle: const Text('Students can mark attendance after session starts'),
                              value: _allowLateEntry,
                              onChanged: (value) {
                                setState(() {
                                  _allowLateEntry = value;
                                });
                              },
                              activeColor: const Color(0xFF2196F3),
                            ),
                            if (_allowLateEntry) ...[
                              const Divider(),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Row(
                                  children: [
                                    const Text('Late entry allowed for: '),
                                    Expanded(
                                      child: Slider(
                                        value: _lateEntryMinutes.toDouble(),
                                        min: 5,
                                        max: 60,
                                        divisions: 11,
                                        label: '$_lateEntryMinutes minutes',
                                        onChanged: (value) {
                                          setState(() {
                                            _lateEntryMinutes = value.round();
                                          });
                                        },
                                        activeColor: const Color(0xFF2196F3),
                                      ),
                                    ),
                                    Text('$_lateEntryMinutes min'),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Create Button
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Create Session',
                        onPressed: _isLoading ? () {} : _createSession,
                        isLoading: _isLoading,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }
}
