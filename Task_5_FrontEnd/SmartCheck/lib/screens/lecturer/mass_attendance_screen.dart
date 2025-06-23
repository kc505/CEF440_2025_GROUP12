import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:smartcheck/models/course.dart';
import 'package:smartcheck/models/session.dart';
import 'package:smartcheck/models/student.dart';
import 'package:smartcheck/services/camera_service.dart';
import 'package:smartcheck/utils/app_theme.dart';
import 'package:smartcheck/widgets/custom_button.dart';

class MassAttendanceScreen extends StatefulWidget {
  final Course course;
  final Session session;

  const MassAttendanceScreen({
    super.key,
    required this.course,
    required this.session,
  });

  @override
  State<MassAttendanceScreen> createState() => _MassAttendanceScreenState();
}

class _MassAttendanceScreenState extends State<MassAttendanceScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isScanning = false;
  List<Student> _detectedStudents = [];
  List<Student> _confirmedStudents = [];
  String _statusMessage = 'Initializing camera...';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameraController = await CameraService.initializeCameraController();
      
      if (_cameraController != null) {
        setState(() {
          _isCameraInitialized = true;
          _statusMessage = 'Camera ready. Tap "Start Scanning" to detect students.';
        });
      } else {
        setState(() {
          _statusMessage = 'Camera not available. Please check permissions.';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error initializing camera: ${e.toString()}';
      });
    }
  }

  Future<void> _startScanning() async {
    setState(() {
      _isScanning = true;
      _statusMessage = 'Scanning for students... Please ensure students are visible in the camera.';
    });

    // Simulate face detection and recognition
    await _simulateFaceDetection();
  }

  Future<void> _simulateFaceDetection() async {
    // Simulate detection process
    for (int i = 0; i < 5; i++) {
      await Future.delayed(const Duration(seconds: 2));
      
      if (!_isScanning) break;
      
      // Simulate detecting a student
      final mockStudents = [
        Student(
          id: 'STU001',
          username: 'john_doe',
          password: '',
          firstName: 'John',
          lastName: 'Doe',
          email: 'john.doe@example.com',
          role: 'Student',
          phoneNumber: '123456789',
          registrationDate: DateTime.now(),
          matriculeNumber: 'FE22A001',
          department: 'Computer Engineering',
          program: 'BEng Computer Engineering',
          admissionYear: 2022,
          enrolledCourses: [widget.course.code],
          academicStatus: 'Active',
          gpa: 3.5,
          totalCredits: 60,
        ),
        Student(
          id: 'STU002',
          username: 'jane_smith',
          password: '',
          firstName: 'Jane',
          lastName: 'Smith',
          email: 'jane.smith@example.com',
          role: 'Student',
          phoneNumber: '123456790',
          registrationDate: DateTime.now(),
          matriculeNumber: 'FE22A002',
          department: 'Computer Engineering',
          program: 'BEng Computer Engineering',
          admissionYear: 2022,
          enrolledCourses: [widget.course.code],
          academicStatus: 'Active',
          gpa: 3.8,
          totalCredits: 58,
        ),
        Student(
          id: 'STU003',
          username: 'mike_johnson',
          password: '',
          firstName: 'Michael',
          lastName: 'Johnson',
          email: 'mike.johnson@example.com',
          role: 'Student',
          phoneNumber: '123456791',
          registrationDate: DateTime.now(),
          matriculeNumber: 'FE22A003',
          department: 'Computer Engineering',
          program: 'BEng Computer Engineering',
          admissionYear: 2022,
          enrolledCourses: [widget.course.code],
          academicStatus: 'Active',
          gpa: 3.2,
          totalCredits: 55,
        ),
      ];

      if (i < mockStudents.length && mounted) {
        setState(() {
          _detectedStudents.add(mockStudents[i]);
          _statusMessage = 'Detected ${_detectedStudents.length} student(s). Continue scanning or confirm attendance.';
        });
      }
    }

    if (mounted) {
      setState(() {
        _isScanning = false;
        _statusMessage = 'Scanning completed. Review detected students and confirm attendance.';
      });
    }
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
      _statusMessage = 'Scanning stopped. Review detected students.';
    });
  }

  void _toggleStudentSelection(Student student) {
    setState(() {
      if (_confirmedStudents.contains(student)) {
        _confirmedStudents.remove(student);
      } else {
        _confirmedStudents.add(student);
      }
    });
  }

  void _handleStartScanning() {
    if (_isCameraInitialized) {
      _startScanning();
    }
  }

  void _handleConfirmAttendance() {
    if (_detectedStudents.isNotEmpty) {
      _confirmAttendance();
    }
  }

  void _doNothing() {
    // Empty function for disabled buttons
  }

  Future<void> _confirmAttendance() async {
    if (_confirmedStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one student to mark attendance.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Attendance'),
        content: Text(
          'Mark attendance for ${_confirmedStudents.length} selected student(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Save attendance to database
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Attendance marked for ${_confirmedStudents.length} student(s)!'),
            backgroundColor: AppTheme.successColor,
          ),
        );

        Navigator.pop(context, _confirmedStudents);
      }
    }
  }

  @override
  void dispose() {
    CameraService.disposeCameraController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mass Attendance'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
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
                  '${widget.course.code}: ${widget.course.name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Session: ${widget.session.title}',
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
              ],
            ),
          ),
          
          // Camera and detection area
          Expanded(
            child: Row(
              children: [
                // Camera preview
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Colors.black,
                    child: _isCameraInitialized && _cameraController != null
                        ? Stack(
                            children: [
                              // Camera preview
                              SizedBox(
                                width: double.infinity,
                                height: double.infinity,
                                child: CameraPreview(_cameraController!),
                              ),
                              
                              // Face detection overlays (simulated)
                              if (_isScanning) ...[
                                for (int i = 0; i < _detectedStudents.length; i++)
                                  Positioned(
                                    top: 50.0 + (i * 100),
                                    left: 50.0 + (i * 80),
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppTheme.successColor,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _detectedStudents[i].firstName.substring(0, 2).toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                              
                              // Status overlay
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  color: Colors.black54,
                                  child: Text(
                                    _statusMessage,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.camera_alt,
                                  size: 80,
                                  color: Colors.white54,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _statusMessage,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                
                // Detected students list
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.grey[50],
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          color: AppTheme.primaryColor,
                          child: Text(
                            'Detected Students (${_detectedStudents.length})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _detectedStudents.length,
                            itemBuilder: (context, index) {
                              final student = _detectedStudents[index];
                              final isSelected = _confirmedStudents.contains(student);
                              
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: CheckboxListTile(
                                  value: isSelected,
                                  onChanged: (_) => _toggleStudentSelection(student),
                                  secondary: CircleAvatar(
                                    backgroundColor: isSelected 
                                        ? AppTheme.successColor 
                                        : AppTheme.primaryColor,
                                    child: Text(
                                      student.initials,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    student.fullName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student.matriculeNumber,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        'Confidence: 95%',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.green[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Control buttons
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                if (!_isScanning) ...[
                  Expanded(
                    child: CustomButton(
                      text: 'Start Scanning',
                      onPressed: _isCameraInitialized ? _handleStartScanning : _doNothing,
                      isPrimary: true,
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: CustomButton(
                      text: 'Stop Scanning',
                      onPressed: _stopScanning,
                      isPrimary: false,
                    ),
                  ),
                ],
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Confirm Attendance (${_confirmedStudents.length})',
                    onPressed: _detectedStudents.isNotEmpty ? _handleConfirmAttendance : _doNothing,
                    isPrimary: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
