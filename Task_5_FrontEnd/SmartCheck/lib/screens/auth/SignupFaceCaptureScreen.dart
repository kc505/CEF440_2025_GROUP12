import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:smartcheck/screens/auth/SignupSuccessScreen.dart';
import 'package:smartcheck/utils/app_theme.dart';
import 'package:smartcheck/services/camera_service.dart';

class SignupFaceCaptureScreen extends StatefulWidget {
  final String name;
  final String email;
  final String password;
  final String role;

  const SignupFaceCaptureScreen({
    super.key,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  State<SignupFaceCaptureScreen> createState() => _SignupFaceCaptureScreenState();
}

class _SignupFaceCaptureScreenState extends State<SignupFaceCaptureScreen>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  String _statusMessage = 'Position your face clearly in the circle';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _setupAnimations();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  Future<void> _initializeCamera() async {
    try {
      _cameraController = await CameraService.initializeCameraController();
      if (_cameraController != null) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      _showError('Failed to initialize camera: $e');
    }
  }

  Future<void> _captureAndRegister() async {
    if (!_isCameraInitialized || _isProcessing) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Capturing and processing...';
    });

    try {
      final XFile? picture = await CameraService.takePicture();
      if (picture == null) throw Exception('Could not capture photo');

      final bytes = await picture.readAsBytes();
      final base64Image = base64Encode(bytes);

      setState(() {
        _statusMessage = 'Registering your account...';
      });

      // Replace with your actual API endpoint
      const String apiUrl = "http://localhost:5000/api/face/register";

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "name": widget.name,
          "email": widget.email,
          "password": widget.password,
          "role": widget.role,
          "imageBase64": base64Image,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        // Navigate to success screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SignupSuccessScreen(
              userName: widget.name,
              userRole: widget.role,
            ),
          ),
        );
      } else {
        final errorData = jsonDecode(response.body);
        _showError(errorData['message'] ?? 'Registration failed');
      }
    } catch (e) {
      _showError("Registration failed: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusMessage = 'Position your face clearly in the circle';
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _retryCapture() {
    setState(() {
      _isProcessing = false;
      _statusMessage = 'Position your face clearly in the circle';
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    CameraService.disposeCameraController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Face Capture', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isProcessing ? null : () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Status header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.black87,
              child: Column(
                children: [
                  Text(
                    _statusMessage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (!_isProcessing) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Make sure your face is well-lit and clearly visible',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),

            // Camera view
            Expanded(
              child: _isCameraInitialized && _cameraController != null
                  ? Stack(
                children: [
                  // Camera preview
                  SizedBox.expand(
                    child: CameraPreview(_cameraController!),
                  ),

                  // Overlay with face guide
                  Center(
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _isProcessing ? 1.0 : _pulseAnimation.value,
                          child: Container(
                            width: 280,
                            height: 350,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(140),
                              border: Border.all(
                                color: _isProcessing
                                    ? AppTheme.primaryColor
                                    : Colors.white,
                                width: 4,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Processing overlay
                  if (_isProcessing)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: AppTheme.primaryColor,
                              strokeWidth: 3,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Processing...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              )
                  : const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryColor,
                ),
              ),
            ),

            // Bottom controls
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.black,
              child: Column(
                children: [
                  // Capture button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _captureAndRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        'Capture & Register',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Help text
                  Text(
                    'Hold still and tap capture when your face is centered',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
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