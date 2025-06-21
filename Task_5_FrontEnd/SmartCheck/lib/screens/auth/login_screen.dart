import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartcheck/providers/auth_provider.dart';
import 'package:smartcheck/screens/auth/signup_screen.dart';
import 'package:smartcheck/screens/home/home_screen.dart';
import 'package:smartcheck/screens/lecturer/lecturer_home_screen.dart';
import 'package:smartcheck/screens/admin/admin_dashboard_screen.dart';
import 'package:smartcheck/utils/app_theme.dart';
import 'package:smartcheck/widgets/custom_button.dart';
import 'package:smartcheck/widgets/custom_text_field.dart';
import 'package:smartcheck/widgets/app_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController(); // Matricule/Faculty Number/Email
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _selectedRole = 'student'; // Default role

  @override
  void dispose() {
    _identifierController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        bool success = false;

        // Call appropriate login method based on role
        switch (_selectedRole) {
          case 'student':
            success = await authProvider.loginStudent(
              _identifierController.text.trim(),
              _emailController.text.trim(),
              _passwordController.text,
            );
            break;
          case 'lecturer':
            success = await authProvider.loginLecturer(
              _identifierController.text.trim(),
              _emailController.text.trim(),
              _passwordController.text,
            );
            break;
          case 'admin':
            success = await authProvider.loginAdmin(
              _emailController.text.trim(),
              _passwordController.text,
            );
            break;
        }

        if (success && mounted) {
          // Navigate to appropriate home screen based on role
          Widget targetScreen;
          switch (_selectedRole) {
            case 'student':
              targetScreen = const HomeScreen();
              break;
            case 'lecturer':
              targetScreen = const LecturerHomeScreen();
              break;
            case 'admin':
              targetScreen = const AdminDashboardScreen();
              break;
            default:
              targetScreen = const HomeScreen();
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => targetScreen),
          );
        } else if (mounted) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login failed. Please check your credentials.'),
              backgroundColor: AppTheme.errorColor,
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

  String _getIdentifierLabel() {
    switch (_selectedRole) {
      case 'student':
        return 'Matricule Number';
      case 'lecturer':
        return 'Faculty Number';
      case 'admin':
        return 'Email';
      default:
        return 'Identifier';
    }
  }

  String _getIdentifierHint() {
    switch (_selectedRole) {
      case 'student':
        return 'Enter your matricule number';
      case 'lecturer':
        return 'Enter your faculty number';
      case 'admin':
        return 'Enter your email address';
      default:
        return '';
    }
  }

  IconData _getIdentifierIcon() {
    switch (_selectedRole) {
      case 'student':
        return Icons.badge_outlined;
      case 'lecturer':
        return Icons.work_outline;
      case 'admin':
        return Icons.email_outlined;
      default:
        return Icons.person_outline;
    }
  }

  String? _validateIdentifier(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your ${_getIdentifierLabel().toLowerCase()}';
    }
    
    if (_selectedRole == 'admin') {
      // For admin, identifier is email, so validate email format
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        return 'Please enter a valid email address';
      }
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        const SizedBox(height: 8),
                        Text(
                          'Login',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select your role and fill in the details below',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
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
                        Expanded(
                          child: _buildRoleOption('admin', 'Admin'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Dynamic identifier field (Matricule/Faculty Number/Email for admin)
                  CustomTextField(
                    label: _getIdentifierLabel(),
                    controller: _selectedRole == 'admin' ? _emailController : _identifierController,
                    prefixIcon: Icon(_getIdentifierIcon()),
                    keyboardType: _selectedRole == 'admin' 
                        ? TextInputType.emailAddress 
                        : TextInputType.text,
                    validator: _validateIdentifier,
                  ),
                  const SizedBox(height: 20),
                  
                  // Email field (only for student and lecturer)
                  if (_selectedRole != 'admin') ...[
                    CustomTextField(
                      label: 'Email',
                      controller: _emailController,
                      prefixIcon: const Icon(Icons.email_outlined),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                  
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
                  
                  // Forgot password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Navigate to forgot password screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Forgot Password - Coming Soon')),
                        );
                      },
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Login button
                  CustomButton(
                    text: 'Login as ${_selectedRole.toUpperCase()}',
                    onPressed: _login,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 20),
                  
                  // Sign up link (only for students and lecturers)
                  if (_selectedRole != 'admin') ...[
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignupScreen(),
                                ),
                              );
                            },
                            child: const Text('Sign up'),
                          ),
                        ],
                      ),
                    ),
                  ],
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
          // Clear controllers when role changes
          _identifierController.clear();
          _emailController.clear();
          _passwordController.clear();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.horizontal(
            left: role == 'student' ? const Radius.circular(8) : Radius.zero,
            right: role == 'admin' ? const Radius.circular(8) : Radius.zero,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
