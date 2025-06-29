import 'dart:convert';
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

  // Additional user info needed for signup
  final String username;
  final String phoneNumber;
  final String matriculeNumber;
  final String department;
  final String specialization;

  const SignupFaceCaptureScreen({
    super.key,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.username,
    required this.phoneNumber,
    required this.matriculeNumber,
    required this.department,
    required this.specialization,
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
      final base64ImageData = base64Encode(bytes);

      // Add data URI prefix so backend knows the image type
      final base64Image = 'data:image/jpeg;base64,$base64ImageData';

      setState(() {
        _statusMessage = 'Registering your face data...';
      });

      // Use email as studentId or change to your user id logic
      final studentId = widget.email; // or any unique id you want to use

      const String faceApiUrl = "http://localhost:5001/register";
      final faceResponse = await http.post(
        Uri.parse(faceApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "studentId": studentId,
          "imageBase64": base64Image,
          // optionally "isActive": "true",
        }),
      ).timeout(const Duration(seconds: 30));

      if (faceResponse.statusCode == 200 || faceResponse.statusCode == 201) {
        setState(() {
          _statusMessage = 'Face data registered! Completing signup...';
        });

        // Proceed with your signup API call as is
        const String signupApiUrl = "http://localhost:5000/api/auth/signup";
        final signupResponse = await http.post(
          Uri.parse(signupApiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "name": widget.name,
            "email": widget.email,
            "password": widget.password,
            "role": widget.role,
            "username": widget.username,
            "phoneNumber": widget.phoneNumber,
            "matriculeNumber": widget.matriculeNumber,
            "department": widget.department,
            "specialization": widget.specialization,
          }),
        ).timeout(const Duration(seconds: 30));

        if (signupResponse.statusCode == 200 || signupResponse.statusCode == 201) {
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
          _handleSignupError(signupResponse);
        }
      } else {
        _handleFaceRegistrationError(faceResponse);
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

  void _handleFaceRegistrationError(http.Response response) {
    print("Face registration failed!");
    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    String errorMessage;
    try {
      final errorData = jsonDecode(response.body);
      errorMessage = errorData['detail'] ?? errorData['error'] ?? 'Face registration failed';
    } catch (_) {
      errorMessage = 'Face registration failed with unexpected response: ${response.body}';
    }

    _showError(errorMessage);
  }

  void _handleSignupError(http.Response response) {
    print("Signup failed!");
    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    String errorMessage;
    try {
      final errorData = jsonDecode(response.body);
      errorMessage = errorData['detail'] ?? errorData['error'] ?? 'Signup failed';
    } catch (_) {
      errorMessage = 'Signup failed with unexpected response: ${response.body}';
    }

    _showError(errorMessage);
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

            Expanded(
              child: _isCameraInitialized && _cameraController != null
                  ? Stack(
                children: [
                  SizedBox.expand(
                    child: CameraPreview(_cameraController!),
                  ),
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

            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.black,
              child: Column(
                children: [
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