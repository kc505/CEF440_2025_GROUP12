import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:smartcheck/models/course.dart';
import 'package:smartcheck/screens/lecturer/edit_attendance_screen.dart';
import 'package:smartcheck/utils/app_theme.dart';
import 'package:smartcheck/services/camera_service.dart';
import 'package:smartcheck/widgets/app_logo.dart';

class SessionAttendanceScreen extends StatefulWidget {
  final Course course;
  final Map<String, dynamic> sessionDetails;

  const SessionAttendanceScreen({
    super.key,
    required this.course,
    required this.sessionDetails,
  });

  @override
  State<SessionAttendanceScreen> createState() => _SessionAttendanceScreenState();
}

class _SessionAttendanceScreenState extends State<SessionAttendanceScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  final bool _isProcessing = false;
  bool _isSessionActive = true;
  List<Map<String, dynamic>> _recognizedStudents = [];
  String _statusMessage = 'Initializing camera...';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _simulateStudentRecognition();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameraController = await CameraService.initializeCameraController();
      
      if (_cameraController != null) {
        setState(() {
          _isCameraInitialized = true;
          _statusMessage = 'Camera ready. Scanning for students...';
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

  // Simulate student recognition for demo purposes
  void _simulateStudentRecognition() {
    // Initial students
    _recognizedStudents = [
      {'id': '1', 'name': 'John Doe', 'time': '10:02 AM', 'confidence': 0.95},
      {'id': '2', 'name': 'Jane Smith', 'time': '10:03 AM', 'confidence': 0.92},
    ];
    
    // Simulate more students being recognized over time
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isSessionActive) {
        setState(() {
          _recognizedStudents.add({
            'id': '3',
            'name': 'Michael Johnson',
            'time': '10:05 AM',
            'confidence': 0.89,
          });
        });
      }
    });
    
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && _isSessionActive) {
        setState(() {
          _recognizedStudents.add({
            'id': '4',
            'name': 'Emily Williams',
            'time': '10:07 AM',
            'confidence': 0.94,
          });
        });
      }
    });
    
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted && _isSessionActive) {
        setState(() {
          _recognizedStudents.add({
            'id': '5',
            'name': 'David Brown',
            'time': '10:09 AM',
            'confidence': 0.91,
          });
        });
      }
    });
  }

  void _endSession() {
    setState(() {
      _isSessionActive = false;
    });
    
    // TODO: Implement API call to end session and save attendance data
    
    // Navigate to edit attendance screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EditAttendanceScreen(
          course: widget.course,
          sessionDetails: widget.sessionDetails,
          recognizedStudents: _recognizedStudents,
        ),
      ),
    );
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
        title: Row(
          children: [
            const AppLogo(height: 28),
            const SizedBox(width: 8),
            Text('${widget.course.code} - Session'),
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
                  '${widget.sessionDetails['date']} at ${widget.sessionDetails['time']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                Text(
                  'Venue: ${widget.sessionDetails['venue']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          
          // Camera view and recognized students
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
                              
                              // Face detection overlay (simulated)
                              if (_isSessionActive) ...[
                                Positioned(
                                  top: 50,
                                  left: 50,
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
                                    child: const Center(
                                      child: Text(
                                        'Face 1',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 150,
                                  right: 80,
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
                                    child: const Center(
                                      child: Text(
                                        'Face 2',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
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
                                      fontSize: 16,
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
                
                // Recognized students list
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
                            'Recognized Students (${_recognizedStudents.length})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _recognizedStudents.length,
                            itemBuilder: (context, index) {
                              final student = _recognizedStudents[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppTheme.successColor,
                                    child: Text(
                                      student['name'].substring(0, 2).toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    student['name'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Time: ${student['time']}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        'Confidence: ${(student['confidence'] * 100).toInt()}%',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(
                                    Icons.check_circle,
                                    color: AppTheme.successColor,
                                    size: 20,
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditAttendanceScreen(
                              course: widget.course,
                              sessionDetails: widget.sessionDetails,
                              recognizedStudents: _recognizedStudents,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Attendance'),
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
}
