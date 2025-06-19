import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartcheck/providers/auth_provider.dart';
import 'package:smartcheck/utils/app_theme.dart';
import 'package:smartcheck/models/student.dart';

class StudentDetailsScreen extends StatefulWidget {
  const StudentDetailsScreen({super.key});

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _matriculeController = TextEditingController();
  final _departmentController = TextEditingController();
  final _programController = TextEditingController();
  
  bool _isEditing = false;
  File? _profileImage;
  String? _profileImagePath;
  final ImagePicker _picker = ImagePicker();
  
  Student? _currentStudent;

  @override
  void initState() {
    super.initState();
    _initializeStudentData();
    _loadProfileImage();
  }

  void _initializeStudentData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      _currentStudent = authProvider.currentUser!;
    } else {
      // Fallback to mock data if no current user
      _currentStudent = Student(
        id: 'STU001',
        username: 'ash',
        password: 'password123',
        firstName: 'Mekole',
        lastName: 'Ashley',
        email: 'mekoleash@gmail.com',
        role: 'Student',
        phoneNumber: '677030466',
        registrationDate: DateTime.now().subtract(const Duration(days: 365)),
        profileImageURL: null,
        matriculeNumber: 'CE/2023/001',
        department: 'Computer Engineering',
        program: 'BEng Computer Engineering',
        admissionYear: 2023,
        enrolledCourses: ['CE101', 'MAT101', 'PHY101'],
        academicStatus: 'Active',
      );
    }
    
    _loadUserData();
  }

  void _loadUserData() {
    if (_currentStudent != null) {
      _usernameController.text = _currentStudent!.username;
      _firstNameController.text = _currentStudent!.firstName;
      _lastNameController.text = _currentStudent!.lastName;
      _emailController.text = _currentStudent!.email;
      _phoneController.text = _currentStudent!.phoneNumber;
      _matriculeController.text = _currentStudent!.matriculeNumber;
      _departmentController.text = _currentStudent!.department;
      _programController.text = _currentStudent!.program;
    }
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

  Future<void> _saveProfileImage(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', imagePath);
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
          _profileImagePath = image.path;
        });
        await _saveProfileImage(image.path);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to pick image. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _matriculeController.dispose();
    _departmentController.dispose();
    _programController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStudent == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Student Details'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Details'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveChanges();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture Section
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        backgroundImage: _profileImage != null 
                            ? FileImage(_profileImage!) 
                            : (_currentStudent!.profileImageURL != null 
                                ? NetworkImage(_currentStudent!.profileImageURL!) 
                                : null) as ImageProvider?,
                        child: (_profileImage == null && _currentStudent!.profileImageURL == null)
                            ? Text(
                                _currentStudent!.initials,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppTheme.primaryColor,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Account Information
                _buildSectionHeader('Account Information'),
                _buildDetailCard([
                  _buildTextField(
                    controller: _usernameController,
                    label: 'Username',
                    icon: Icons.account_circle,
                    enabled: _isEditing,
                  ),
                  // Fixed: Use Column instead of Row for better space management
                  _buildTextField(
                    controller: _firstNameController,
                    label: 'First Name',
                    icon: Icons.person,
                    enabled: _isEditing,
                  ),
                  _buildTextField(
                    controller: _lastNameController,
                    label: 'Last Name',
                    icon: Icons.person,
                    enabled: _isEditing,
                  ),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    icon: Icons.email,
                    enabled: _isEditing,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone,
                    enabled: _isEditing,
                    keyboardType: TextInputType.phone,
                  ),
                ]),
                
                const SizedBox(height: 24),

                // Academic Information
                _buildSectionHeader('Academic Information'),
                _buildDetailCard([
                  _buildTextField(
                    controller: _matriculeController,
                    label: 'Matricule Number',
                    icon: Icons.badge,
                    enabled: false, // Matricule should not be editable
                  ),
                  _buildTextField(
                    controller: _departmentController,
                    label: 'Department',
                    icon: Icons.school,
                    enabled: _isEditing,
                  ),
                  _buildTextField(
                    controller: _programController,
                    label: 'Program',
                    icon: Icons.book,
                    enabled: _isEditing,
                  ),
                  // Fixed: Use individual info tiles instead of rows
                  _buildInfoTile('Admission Year', '${_currentStudent!.admissionYear}', Icons.calendar_today),
                  _buildInfoTile('Current Year', '${_currentStudent!.currentYear}', Icons.grade),
                  _buildInfoTile('Academic Level', _currentStudent!.academicLevel, Icons.star),
                  _buildInfoTile('Role', _currentStudent!.role, Icons.person_outline),
                ]),

                const SizedBox(height: 24),

                // Academic Performance
                _buildSectionHeader('Academic Performance'),
                _buildDetailCard([
                  _buildInfoTile('GPA', _currentStudent!.gpa?.toStringAsFixed(2) ?? 'N/A', Icons.grade),
                  _buildInfoTile('Credits', '${_currentStudent!.totalCredits}', Icons.book),
                  _buildInfoTile('Enrolled Courses', '${_currentStudent!.enrolledCourses.length}', Icons.class_),
                  _buildInfoTile('Status', _currentStudent!.academicStatus, Icons.check_circle),
                ]),

                const SizedBox(height: 24),

                // System Information
                _buildSectionHeader('System Information'),
                _buildDetailCard([
                  _buildInfoTile('Registration Date', _currentStudent!.registrationDate.toString().split(' ')[0], Icons.date_range),
                  _buildInfoTile('Account Status', _currentStudent!.isActive ? 'Active' : 'Inactive', Icons.account_circle),
                ]),

                const SizedBox(height: 24),

                // Attendance Statistics
                _buildSectionHeader('Attendance Statistics'),
                _buildStatsCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.primaryColor),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        validator: (value) {
          if (enabled && (value == null || value.isEmpty)) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Container(
      width: double.infinity, // Fixed: Ensure full width
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded( // Fixed: Use Expanded to prevent overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis, // Fixed: Handle text overflow
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatRow('Total Sessions', '${_currentStudent!.totalSessions}'),
            const Divider(height: 20),
            _buildStatRow('Attended Sessions', '${_currentStudent!.attendedSessions}'),
            const Divider(height: 20),
            _buildStatRow('Attendance Rate', '${_currentStudent!.attendanceRate.toStringAsFixed(1)}%'),
            const Divider(height: 20),
            _buildStatRow('Attendance Status', _currentStudent!.attendanceStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded( // Fixed: Use Expanded to prevent overflow
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded( // Fixed: Use Expanded for value as well
            flex: 1,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isEditing = false;
        // Update the student object with new values
        _currentStudent = _currentStudent!.copyWith(
          username: _usernameController.text,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          email: _emailController.text,
          phoneNumber: _phoneController.text,
          department: _departmentController.text,
          program: _programController.text,
          updatedAt: DateTime.now(),
        );
      });
      
      // Update the AuthProvider with the new user data
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.updateCurrentUser(_currentStudent!);
      
      // TODO: Save to API/database
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
