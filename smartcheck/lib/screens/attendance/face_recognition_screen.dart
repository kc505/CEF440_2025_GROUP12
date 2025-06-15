import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:smartcheck/models/course.dart';
import 'package:smartcheck/screens/attendance/face_result_screen.dart';
import 'package:smartcheck/screens/attendance/geofence_screen.dart';
import 'package:smartcheck/utils/app_theme.dart';
import 'package:smartcheck/services/camera_service.dart';

class FaceRecognitionScreen extends StatefulWidget {
  final Course course;

  const FaceRecognitionScreen({
    super.key,
    required this.course,
  });

  @override
  State<FaceRecognitionScreen> createState() => _FaceRecognitionScreenState();
}

class _FaceRecognitionScreenState extends State<FaceRecognitionScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  bool _isCapturing = false;
  String _statusMessage = 'Position your face within the circle';

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

  Future<void> _captureAndProcessFace() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
      _isProcessing = true;
      _statusMessage = 'Capturing face...';
    });

    try {
      // Take picture
      final XFile? picture = await CameraService.takePicture();
      
      if (picture != null) {
        setState(() {
          _statusMessage = 'Processing facial recognition...';
        });

        // TODO: Implement actual facial recognition API call here
        // For now, simulate processing time
        await Future.delayed(const Duration(seconds: 3));

        // Simulate recognition result (in real app, this would come from API)
        final bool recognitionSuccess = await _simulateFaceRecognition(picture);

        if (mounted) {
          if (recognitionSuccess) {
            // Navigate to geofence verification
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => GeofenceScreen(course: widget.course),
              ),
            );
          } else {
            // Navigate to failure screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => FaceResultScreen(
                  isSuccess: false,
                  course: widget.course,
                ),
              ),
            );
          }
        }
      } else {
        setState(() {
          _statusMessage = 'Failed to capture image. Please try again.';
          _isProcessing = false;
          _isCapturing = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error capturing face: ${e.toString()}';
        _isProcessing = false;
        _isCapturing = false;
      });
    }
  }

  // Simulate facial recognition processing
  Future<bool> _simulateFaceRecognition(XFile picture) async {
    // TODO: Replace with actual facial recognition API call
    // This would typically involve:
    // 1. Converting image to base64 or uploading to server
    // 2. Calling facial recognition API
    // 3. Comparing with stored face template
    // 4. Returning recognition result
    
    // For demo purposes, return true (successful recognition)
    return true;
  }

  @override
  void dispose() {
    CameraService.disposeCameraController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Facial Recognition'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Status message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.black87,
              child: Text(
                _statusMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // Camera preview
            Expanded(
              child: _isCameraInitialized && _cameraController != null
                  ? Stack(
                      children: [
                        // Camera preview
                        SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: CameraPreview(_cameraController!),
                        ),
                        
                        // Face detection overlay
                        Center(
                          child: Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _isProcessing 
                                    ? AppTheme.primaryColor 
                                    : Colors.white,
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                        
                        // Processing indicator
                        if (_isProcessing)
                          Container(
                            color: Colors.black54,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: AppTheme.primaryColor,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Processing...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
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
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _initializeCamera,
                            child: const Text('Retry Camera'),
                          ),
                        ],
                      ),
                    ),
            ),
            
            // Capture button
            if (_isCameraInitialized && !_isProcessing)
              Container(
                padding: const EdgeInsets.all(24),
                color: Colors.black87,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _captureAndProcessFace,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryColor,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
