import 'package:flutter/material.dart';
import 'package:smartcheck/screens/auth/SignupFaceCaptureScreen.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _matriculeController = TextEditingController();
  final _departmentController = TextEditingController();
  final _specializationController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    _matriculeController.dispose();
    _departmentController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      // Navigate to face capture screen with all user data
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignupFaceCaptureScreen(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
              role: 'student',
              username: _usernameController.text.trim(),
              phoneNumber: _phoneNumberController.text.trim(),
              matriculeNumber: _matriculeController.text.trim(),
              department: _departmentController.text.trim(),
              specialization: _specializationController.text.trim(),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Signup')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  label: 'Full Name',
                  controller: _nameController,
                  validator: (val) => val!.isEmpty ? 'Enter your name' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Username',
                  controller: _usernameController,
                  validator: (val) => val!.isEmpty ? 'Enter a username' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter email';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) return 'Invalid email';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (val) => (val == null || val.length < 6) ? 'Min 6 characters' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Phone Number',
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Matricule Number',
                  controller: _matriculeController,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Department',
                  controller: _departmentController,
                  validator: (val) => val!.isEmpty ? 'Enter department' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Specialization',
                  controller: _specializationController,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Proceed to Face Capture',
                  onPressed: _submit,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
