import 'package:flutter/material.dart';
import 'package:smartcheck/models/course.dart';
import 'package:smartcheck/utils/app_theme.dart';

class GeofenceResultScreen extends StatelessWidget {
  final bool isSuccess;
  final Course course;

  const GeofenceResultScreen({
    super.key,
    required this.isSuccess,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location ${isSuccess ? 'Verified' : 'Failed'}'),
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
                    
                    // Center result indicator
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: isSuccess ? AppTheme.successColor : AppTheme.errorColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (isSuccess ? AppTheme.successColor : AppTheme.errorColor).withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          isSuccess ? Icons.check : Icons.close,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // Result text
              Text(
                isSuccess ? 'Location Verified' : 'Your not in required location',
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
                      // TODO: Submit attendance to backend API
                      _submitAttendance(context);
                    } else {
                      // Go back to try again
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: isSuccess ? AppTheme.successColor : AppTheme.primaryColor,
                  ),
                  child: Text(
                    isSuccess ? 'Submit Attendance' : 'Try Again',
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

  void _submitAttendance(BuildContext context) {
    // TODO: Implement actual API call to submit attendance
    // This would include:
    // - Course ID
    // - Student ID
    // - Timestamp
    // - Location coordinates
    // - Face recognition confirmation
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Attendance submitted successfully!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
    
    // Navigate back to home
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}
