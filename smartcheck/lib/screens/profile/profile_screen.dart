import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartcheck/providers/auth_provider.dart';
import 'package:smartcheck/providers/theme_provider.dart';
import 'package:smartcheck/screens/auth/login_screen.dart';
import 'package:smartcheck/screens/profile/settings_screen.dart';
import 'package:smartcheck/screens/profile/student_details_screen.dart';
import 'package:smartcheck/screens/profile/faq_screen.dart';
import 'package:smartcheck/utils/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image_path');
    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() {
        _profileImagePath = imagePath;
        _profileImage = File(imagePath);
      });
    }
  }

  String _getDisplayName(AuthProvider authProvider) {
    if (authProvider.currentUser != null) {
      return authProvider.currentUser!.fullName;
    }
    if (authProvider.userData != null && authProvider.userData!['name'] != null) {
      return authProvider.userData!['name'];
    }
    return 'User Name';
  }

  String _getDisplayEmail(AuthProvider authProvider) {
    if (authProvider.currentUser != null) {
      return authProvider.currentUser!.email;
    }
    if (authProvider.userData != null && authProvider.userData!['email'] != null) {
      return authProvider.userData!['email'];
    }
    return 'user@example.com';
  }

  String _getInitials(AuthProvider authProvider) {
    if (authProvider.currentUser != null) {
      return authProvider.currentUser!.initials;
    }
    final name = _getDisplayName(authProvider);
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ThemeProvider>(
      builder: (context, authProvider, themeProvider, child) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authProvider.userRole == UserRole.student 
                        ? 'Student Profile'
                        : authProvider.userRole == UserRole.lecturer
                            ? 'Lecturer Profile'
                            : 'Admin Profile',
                    style: AppTheme.headingStyle,
                  ),
                  const SizedBox(height: 24),
                  
                  // Profile header
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                            backgroundImage: _profileImage != null 
                                ? FileImage(_profileImage!) 
                                : (authProvider.currentUser?.profileImageURL != null 
                                    ? NetworkImage(authProvider.currentUser!.profileImageURL!) 
                                    : null) as ImageProvider?,
                            child: (_profileImage == null && 
                                   (authProvider.currentUser?.profileImageURL == null || 
                                    authProvider.currentUser?.profileImageURL?.isEmpty == true))
                                ? Text(
                                    _getInitials(authProvider),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getDisplayName(authProvider),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getDisplayEmail(authProvider),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                                if (authProvider.currentUser != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '${authProvider.currentUser!.department} • ${authProvider.currentUser!.program}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Menu items
                  _buildMenuItem(
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  if (authProvider.userRole == UserRole.student)
                    _buildMenuItem(
                      icon: Icons.person,
                      title: 'Student Details',
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StudentDetailsScreen(),
                          ),
                        );
                        // Refresh profile image when returning from details screen
                        if (result == true || result == null) {
                          _loadProfileImage();
                        }
                      },
                    ),
                  _buildSwitchMenuItem(
                    icon: Icons.dark_mode,
                    title: 'Dark Mode',
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value 
                              ? 'Dark mode enabled!' 
                              : 'Light mode enabled!',
                          ),
                          backgroundColor: AppTheme.primaryColor,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.help,
                    title: 'FAQ',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FAQScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showLogoutDialog(context);
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppTheme.primaryColor,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppTheme.textSecondaryColor,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildSwitchMenuItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppTheme.primaryColor,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                authProvider.logout();
                
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
