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
  final String program; // Add this
  final String admissionYear;

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
    required this.program, // Add this
    required this.admissionYear,
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
  double _processingProgress = 0.0;

  late AnimationController _pulseController;
  late AnimationController _processingController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _processingAnimation;

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

    _processingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _processingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _processingController,
      curve: Curves.easeInOut,
    ));
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
      _statusMessage = 'Capturing your face...';
      _processingProgress = 0.0;
    });

    _processingController.repeat();

    try {
      // Simulate face capture
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _statusMessage = 'Processing facial data...';
        _processingProgress = 0.2;
      });

      // Simulate face processing with progress updates
      for (int i = 1; i <= 4; i++) {
        await Future.delayed(const Duration(milliseconds: 1000));
        setState(() {
          _processingProgress = 0.2 + (i * 0.15);
          if (i == 1) _statusMessage = 'Analyzing facial features...';
          if (i == 2) _statusMessage = 'Creating face profile...';
          if (i == 3) _statusMessage = 'Securing your data...';
          if (i == 4) _statusMessage = 'Finalizing registration...';
        });
      }

      setState(() {
        _statusMessage = 'Registering your account...';
        _processingProgress = 0.9;
      });

      // Register user via your signup API
      await _registerUserViaAPI();

      setState(() {
        _processingProgress = 1.0;
        _statusMessage = 'Registration complete!';
      });

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SignupSuccessScreen(
              userName: widget.name,
              userRole: widget.role,
            ),
          ),
        );
      }
    } catch (e) {
      _showError("Registration failed: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusMessage = 'Position your face clearly in the circle';
          _processingProgress = 0.0;
        });
        _processingController.stop();
      }
    }
  }

  Future<void> _registerUserViaAPI() async {
    try {
      // Split name into firstName and lastName
      List<String> nameParts = widget.name.split(' ');
      String firstName = nameParts.first;
      String lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';

      const String signupApiUrl = "http://localhost:5000/api/auth/signup";


      // Create the request body matching your backend exactly
      final requestBody = {
        "email": widget.email,
        "password": widget.password,
        "firstName": firstName,
        "lastName": lastName,
        "role": widget.role,
        "userID": widget.matriculeNumber, // Using matricule as userID
        "username": widget.username,
        // Optional fields - include if not empty
        if (widget.phoneNumber.isNotEmpty) "phoneNumber": widget.phoneNumber,
        if (widget.matriculeNumber.isNotEmpty) "matriculeNumber": widget.matriculeNumber,
        if (widget.department.isNotEmpty) "department": widget.department,
        if (widget.specialization.isNotEmpty) "specialization": widget.specialization,
        if (widget.program.isNotEmpty) "program": widget.program,
        if (widget.admissionYear.isNotEmpty) "admissionYear": int.tryParse(widget.admissionYear),
        // Auto-generated fields
        "registrationDate": DateTime.now().toIso8601String(),
      };

      print('Sending signup request with body: ${jsonEncode(requestBody)}');

      final signupResponse = await http.post(
        Uri.parse(signupApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      print('Signup response status: ${signupResponse.statusCode}');
      print('Signup response body: ${signupResponse.body}');

      if (signupResponse.statusCode != 200 && signupResponse.statusCode != 201) {
        _handleSignupError(signupResponse);
        throw Exception('Signup failed');
      }

      print('User registered successfully via API');
    } catch (e) {
      print('Error registering user via API: $e');
      throw Exception('Failed to register user: $e');
    }
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
    _processingController.dispose();
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
                  if (_isProcessing) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: MediaQuery.of(context).size.width * 0.8 * _processingProgress,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(_processingProgress * 100).toInt()}% Complete',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Camera preview
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
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: CircularProgressIndicator(
                                    value: _processingProgress,
                                    color: AppTheme.primaryColor,
                                    strokeWidth: 4,
                                    backgroundColor: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                AnimatedBuilder(
                                  animation: _processingAnimation,
                                  builder: (context, child) {
                                    return Transform.rotate(
                                      angle: _processingAnimation.value * 2 * 3.14159,
                                      child: Icon(
                                        Icons.face,
                                        color: AppTheme.primaryColor,
                                        size: 32,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                ),
                              ),
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
                        disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.6),
                      ),
                      child: _isProcessing
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                              value: _processingProgress,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Processing...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
                    _isProcessing
                        ? 'Please wait while we process your facial data securely'
                        : 'Hold still and tap capture when your face is centered',
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