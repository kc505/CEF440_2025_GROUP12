import 'package:flutter/material.dart';
import 'package:smartcheck/utils/app_theme.dart';
import 'package:smartcheck/widgets/custom_button.dart';
import 'package:smartcheck/widgets/custom_text_field.dart';
import 'package:smartcheck/widgets/app_logo.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({Key? key}) : super(key: key);

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // TODO: Implement actual password reset API call
        // This would typically:
        // 1. Validate email exists in database
        // 2. Generate secure reset token
        // 3. Send email with reset link
        // 4. Store token with expiration time
        
        await Future.delayed(const Duration(seconds: 2));
        
        setState(() {
          _emailSent = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset email sent successfully!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _resendEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reset email sent again!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  
                  // Header
                  Center(
                    child: Column(
                      children: [
                        const AppLogo(height: 60),
                        const SizedBox(height: 16),
                        Text(
                          _emailSent ? 'Check Your Email' : 'Forgot Password?',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _emailSent 
                              ? 'We\'ve sent a password reset link to your email address.'
                              : 'Enter your email address and we\'ll send you a link to reset your password.',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  if (!_emailSent) ...[
                    // Email field
                    CustomTextField(
                      label: 'Email Address',
                      controller: _emailController,
                      prefixIcon: const Icon(Icons.email_outlined),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email address';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    
                    // Send reset email button
                    CustomButton(
                      text: 'Send Reset Email',
                      onPressed: _sendResetEmail,
                      isLoading: _isLoading,
                    ),
                  ] else ...[
                    // Success state
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.successColor.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.mark_email_read,
                            size: 64,
                            color: AppTheme.successColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Email Sent Successfully!',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.successColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Check your email (${_emailController.text}) for the password reset link.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Didn\'t receive the email? Check your spam folder or try again.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Resend email button
                    CustomButton(
                      text: 'Resend Email',
                      onPressed: _resendEmail,
                      isLoading: _isLoading,
                      isPrimary: false,
                    ),
                    const SizedBox(height: 16),
                    
                    // Back to login button
                    CustomButton(
                      text: 'Back to Login',
                      onPressed: () => Navigator.pop(context),
                      isPrimary: true,
                    ),
                  ],
                  
                  const SizedBox(height: 20),
                  
                  // Help text
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'Need help?',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Navigate to help/support screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Contact Support - Coming Soon')),
                            );
                          },
                          child: const Text('Contact Support'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
