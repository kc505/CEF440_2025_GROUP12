// 1. Updated SignupScreen (Step 1)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartcheck/providers/auth_provider.dart';
import 'package:smartcheck/screens/auth/SignupFaceCaptureScreen.dart';
import 'package:smartcheck/utils/app_theme.dart';
import 'package:smartcheck/widgets/custom_button.dart';
import 'package:smartcheck/widgets/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _selectedRole = 'student';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _proceedToFaceCapture() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Check if email already exists (optional validation)
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final emailExists = await authProvider.checkEmailExists(_emailController.text.trim());

        if (emailExists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email already exists. Please use a different email.'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
          return;
        }

        // Navigate to face capture screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignupFaceCaptureScreen(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
              role: _selectedRole,
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
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
                  const SizedBox(height: 20),
                  // Header
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'SmartCheck',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create an account',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Fill in the fields below to get started',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Role selection
                  const Text(
                    'Select Role',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.dividerColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildRoleOption('student', 'Student'),
                        ),
                        Expanded(
                          child: _buildRoleOption('lecturer', 'Lecturer'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Name field
                  CustomTextField(
                    label: 'Name',
                    controller: _nameController,
                    prefixIcon: const Icon(Icons.person_outline),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      if (value.length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Email field
                  CustomTextField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password field with toggle visibility
                  CustomTextField(
                    label: 'Password',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Info about face capture
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.face,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Next step: We\'ll capture your face for secure attendance tracking',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Continue button
                  CustomButton(
                    text: 'Continue to Face Capture',
                    onPressed: _proceedToFaceCapture,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 20),

                  // Login link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account?'),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Sign in'),
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

  Widget _buildRoleOption(String role, String label) {
    final isSelected = _selectedRole == role;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.horizontal(
            left: role == 'student' ? const Radius.circular(8) : Radius.zero,
            right: role == 'lecturer' ? const Radius.circular(8) : Radius.zero,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
