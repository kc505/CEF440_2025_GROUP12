import 'package:flutter/material.dart';
import 'package:smartcheck/models/course.dart';
import 'package:smartcheck/screens/attendance/attendance_login_screen.dart';
import 'package:smartcheck/utils/app_theme.dart';

class FaceResultScreen extends StatelessWidget {
  final bool isSuccess;
  final Course course;

  const FaceResultScreen({
    super.key,
    required this.isSuccess,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Facial Recognition ${isSuccess ? 'Successful' : 'Failed'}'),
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
              const Text(
                'Ensure that you place your face properly',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Result icon
              Icon(
                isSuccess ? Icons.check_circle : Icons.cancel,
                size: 120,
                color: isSuccess ? AppTheme.successColor : AppTheme.errorColor,
              ),
              const SizedBox(height: 40),
              
              // Result text
              Text(
                isSuccess ? 'Facial Recognition\nSuccessful' : 'Facial Recognition\nFailed',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isSuccess ? AppTheme.successColor : AppTheme.errorColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (isSuccess) {
                      // In a real app, navigate to next step (geofence verification)
                      Navigator.pop(context);
                    } else {
                      // Try again
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AttendanceLoginScreen(course: course),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: isSuccess ? AppTheme.successColor : AppTheme.primaryColor,
                  ),
                  child: Text(
                    isSuccess ? 'Continue' : 'Try Again',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
