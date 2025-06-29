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
  final _admissionYearController = TextEditingController();
  final _programController = TextEditingController();

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
    _admissionYearController.dispose();
    _programController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
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
              program: _programController.text.trim(), // Add this
              admissionYear: _admissionYearController.text.trim(), // Add this
            ),
          ),
        );
      }
    }
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 12),
              height: 1,
              color: Theme.of(context).dividerColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(title, icon),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Student Registration'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).primaryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.only(bottom: 32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.school_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Join SmartCheck',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Complete your registration to get started',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                // Personal Information Section
                _buildFormSection(
                  title: 'Personal Information',
                  icon: Icons.person_outline,
                  children: [
                    CustomTextField(
                      label: 'Full Name',
                      controller: _nameController,
                      prefixIcon: Icon(Icons.person),
                      validator: (val) => val!.isEmpty ? 'Enter your full name' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Username',
                      controller: _usernameController,
                      prefixIcon: Icon(Icons.alternate_email),
                      validator: (val) => val!.isEmpty ? 'Enter a username' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Phone Number',
                      controller: _phoneNumberController,
                      prefixIcon: Icon(Icons.phone),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),

                // Account Security Section
                _buildFormSection(
                  title: 'Account Security',
                  icon: Icons.security,
                  children: [
                    CustomTextField(
                      label: 'Email Address',
                      controller: _emailController,
                      prefixIcon: Icon(Icons.email_outlined),
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Enter email address';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Password',
                      controller: _passwordController,
                      prefixIcon: Icon(Icons.lock_outline),
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey[600],
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (val) => (val == null || val.length < 6)
                          ? 'Password must be at least 6 characters' : null,
                    ),
                  ],
                ),

                // Academic Information Section
                _buildFormSection(
                  title: 'Academic Information',
                  icon: Icons.school,
                  children: [
                    CustomTextField(
                      label: 'Matricule Number',
                      controller: _matriculeController,
                      prefixIcon: Icon(Icons.badge),
                      validator: (val) => val!.isEmpty ? 'Enter your matricule number' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Department',
                      controller: _departmentController,
                      prefixIcon: Icon(Icons.domain),
                      validator: (val) => val!.isEmpty ? 'Enter your department' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Program/Degree',
                      controller: _programController,
                      prefixIcon: Icon(Icons.school_outlined),
                      validator: (val) => val!.isEmpty ? 'Enter your program' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Specialization',
                      controller: _specializationController,
                      prefixIcon: Icon(Icons.auto_awesome),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Admission Year',
                      controller: _admissionYearController,
                      prefixIcon: Icon(Icons.calendar_today),
                      keyboardType: TextInputType.number,
                      validator: (val) => val!.isEmpty ? 'Enter your admission year' : null,
                    ),
                  ],
                ),

                // Submit Button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 8),
                  child: CustomButton(
                    text: 'Proceed to Face Capture',
                    onPressed: _submit,
                    isLoading: _isLoading,
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}