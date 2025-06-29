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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _selectedRole = 'student'; // Default role

  // === Special Admin Credentials ===
  final String adminEmail = 'admin@smartcheck.com';
  final String adminPassword = 'SuperSecret123'; // Change for production

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();

        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        // === Admin Login Bypass ===
        if (email == adminEmail && password == adminPassword && _selectedRole == 'admin') {
          authProvider.setAdminAuthenticated(); // we'll define this function in the AuthProvider

          if (mounted) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
          }
          return;
        }

        // === Normal Firebase Authentication for Students and Lecturers ===
        final success = await authProvider.loginWithFirebase(email, password, _selectedRole);

        if (success && mounted) {
          Widget targetScreen;
          switch (_selectedRole) {
            case 'student':
              targetScreen = const HomeScreen();
              break;
            case 'lecturer':
              targetScreen = const LecturerHomeScreen();
              break;
            case 'admin': // fallback
              targetScreen = const AdminDashboardScreen();
              break;
            default:
              targetScreen = const HomeScreen();
          }
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => targetScreen));
        } else if (mounted) {
          _showError('Login failed. Please check your credentials.');
        }
      } catch (e) {
        _showError('Error: ${e.toString()}');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/smartcheck_logo.png',
                        height: 60,
                      ),
                      Text('Login', style: Theme.of(context).textTheme.displayMedium),
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

                const Text('Select Role', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                _buildRoleSelector(),

                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Email',
                  controller: _emailController,
                  prefixIcon: const Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your email';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Please enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your password';
                    if (value.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Forgot Password - Coming Soon')),
                      );
                    },
                    child: const Text('Forgot password?'),
                  ),
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: 'Login as ${_selectedRole.toUpperCase()}',
                  onPressed: _login,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen()));
                        },
                        child: const Text('Sign up'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: ['student', 'lecturer', 'admin'].map((role) {
          final isSelected = _selectedRole == role;
          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() => _selectedRole = role);
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
                  role[0].toUpperCase() + role.substring(1),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}