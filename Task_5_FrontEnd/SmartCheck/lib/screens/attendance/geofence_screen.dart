import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smartcheck/models/course.dart';
import 'package:smartcheck/screens/attendance/geofence_result_screen.dart';
import 'package:smartcheck/utils/app_theme.dart';

class GeofenceScreen extends StatefulWidget {
  final Course course;

  const GeofenceScreen({
    super.key,
    required this.course,
  });

  @override
  State<GeofenceScreen> createState() => _GeofenceScreenState();
}

class _GeofenceScreenState extends State<GeofenceScreen> {
  bool _isVerifying = true;
  bool _isSuccess = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Simulate geofence verification process
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          // Randomly determine success or failure for demo purposes
          _isSuccess = true; // In a real app, this would be based on actual location verification
        });
        
        // Navigate to result screen after a short delay
        Timer(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => GeofenceResultScreen(
                isSuccess: _isSuccess,
                course: widget.course,
              ),
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Verification'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Map placeholder
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Stack(
                  children: [
                    // Map background
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [Colors.blue[100]!, Colors.blue[50]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    
                    // Street names (simulated)
                    const Positioned(
                      top: 20,
                      left: 20,
                      child: Text(
                        'Ala Moana Blvd',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Positioned(
                      bottom: 20,
                      right: 20,
                      child: Text(
                        'Kahanamoku St',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    
                    // Center location indicator
                    Center(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _isVerifying ? AppTheme.primaryColor : (_isSuccess ? AppTheme.successColor : AppTheme.errorColor),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (_isVerifying ? AppTheme.primaryColor : (_isSuccess ? AppTheme.successColor : AppTheme.errorColor)).withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: _isVerifying
                            ? const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 30,
                              )
                            : Icon(
                                _isSuccess ? Icons.check : Icons.close,
                                color: Colors.white,
                                size: 30,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // Status text
              Text(
                _isVerifying
                    ? 'Verifying Location...'
                    : (_isSuccess ? 'Location Verified' : 'Location Verification Failed'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _isVerifying ? AppTheme.primaryColor : (_isSuccess ? AppTheme.successColor : AppTheme.errorColor),
                ),
              ),
              const SizedBox(height: 16),
              
              // Additional info text
              Text(
                _isVerifying
                    ? 'Checking if you are in the required location...'
                    : (_isSuccess ? 'You are in the correct location for attendance' : 'You are not in the required location'),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              
              if (_isVerifying) ...[
                const SizedBox(height: 20),
                const CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
