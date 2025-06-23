
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_theme.dart';
import '../../models/student.dart';


class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({Key? key}) : super(key: key);

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  List<Student> _students = [];
  List<Student> _filteredStudents = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedDepartment = 'All';
  String _selectedStatus = 'All';
  int _selectedYear = 0; // 0 means all years

  final List<String> _departments = [
    'All',
    'Computer Engineering',
    'Electrical Engineering',
    'Mechanical Engineering',
    'Civil Engineering',
    'Software Engineering'
  ];

  final List<String> _statuses = [
    'All',
    'Active',
    'Suspended',
    'Graduated',
    'Inactive'
  ];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();

      _students = snapshot.docs.map((doc) {
        final data = doc.data();
        return Student(
          id: doc.id,
          username: data['username'] ?? '',
          password: '', // avoid storing passwords client-side
          firstName: data['firstName'] ?? '',
          lastName: data['lastName'] ?? '',
          email: data['email'] ?? '',
          role: data['role'] ?? '',
          phoneNumber: data['phoneNumber'] ?? '',
          registrationDate: (data['registrationDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
          profileImageURL: data['profileImageURL'],
          matriculeNumber: data['matriculeNumber'] ?? '',
          department: data['department'] ?? '',
          program: data['program'] ?? '',
          admissionYear: data['admissionYear'] ?? 0,
          enrolledCourses: List<String>.from(data['enrolledCourses'] ?? []),
          academicStatus: data['academicStatus'] ?? '',
          gpa: (data['gpa'] is num) ? (data['gpa'] as num).toDouble() : null,
          totalCredits: data['totalCredits'] ?? 0,
        );
      }).toList();

      _applyFilters();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading students: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilters() {
    _filteredStudents = _students.where((student) {
      bool matchesSearch = _searchQuery.isEmpty ||
          student.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          student.matriculeNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          student.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          student.username.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesDepartment = _selectedDepartment == 'All' ||
          student.department == _selectedDepartment;

      bool matchesStatus = _selectedStatus == 'All' ||
          student.academicStatus == _selectedStatus;

      bool matchesYear = _selectedYear == 0 ||
          student.currentYear == _selectedYear;

      return matchesSearch && matchesDepartment && matchesStatus && matchesYear;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Manage Students'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add Student - Coming Soon')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStudents,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name, matricule, email, or username...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _applyFilters();
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Filter Dropdowns
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedDepartment,
                        decoration: InputDecoration(
                          labelText: 'Department',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: _departments.map((dept) {
                          return DropdownMenuItem(
                            value: dept,
                            child: Text(dept),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDepartment = value!;
                            _applyFilters();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: _statuses.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                            _applyFilters();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedYear,
                        decoration: InputDecoration(
                          labelText: 'Year',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: [
                          const DropdownMenuItem(value: 0, child: Text('All Years')),
                          const DropdownMenuItem(value: 1, child: Text('Year 1')),
                          const DropdownMenuItem(value: 2, child: Text('Year 2')),
                          const DropdownMenuItem(value: 3, child: Text('Year 3')),
                          const DropdownMenuItem(value: 4, child: Text('Year 4')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedYear = value!;
                            _applyFilters();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Statistics Header
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryColor.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total', '${_students.length}'),
                _buildStatItem('Active', '${_students.where((s) => s.academicStatus == 'Active').length}'),
                _buildStatItem('Graduated', '${_students.where((s) => s.academicStatus == 'Graduated').length}'),
                _buildStatItem('Filtered', '${_filteredStudents.length}'),
              ],
            ),
          ),

          // Students List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredStudents.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No students found',
                    style: AppTheme.bodyStyle.copyWith(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredStudents.length,
              itemBuilder: (context, index) {
                final student = _filteredStudents[index];
                return _buildStudentCard(student);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStudentCard(Student student) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  backgroundImage: student.profileImageURL != null
                      ? NetworkImage(student.profileImageURL!)
                      : null,
                  child: student.profileImageURL == null
                      ? Text(
                    student.initials,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.fullName,
                        style: AppTheme.bodyStyle.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${student.username} • ${student.matriculeNumber}',
                        style: AppTheme.bodyStyle.copyWith(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${student.academicLevel} • ${student.program}',
                        style: AppTheme.bodyStyle.copyWith(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(student.academicStatus).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor(student.academicStatus).withOpacity(0.3)),
                  ),
                  child: Text(
                    student.academicStatus,
                    style: TextStyle(
                      color: _getStatusColor(student.academicStatus),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Student Details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          'Email',
                          student.email,
                          Icons.email,
                        ),
                      ),
                      Expanded(
                        child: _buildDetailItem(
                          'Phone',
                          student.phoneNumber,
                          Icons.phone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          'Department',
                          student.department,
                          Icons.school,
                        ),
                      ),
                      Expanded(
                        child: _buildDetailItem(
                          'Year ${student.currentYear}',
                          'Admission ${student.admissionYear}',
                          Icons.calendar_today,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          'GPA',
                          student.gpa?.toStringAsFixed(2) ?? 'N/A',
                          Icons.grade,
                        ),
                      ),
                      Expanded(
                        child: _buildDetailItem(
                          'Credits',
                          '${student.totalCredits}',
                          Icons.book,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    _showStudentDetails(student);
                  },
                  icon: const Icon(Icons.info, size: 16),
                  label: const Text('Details'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    _editStudent(student);
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    _showDeleteConfirmation(student);
                  },
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'suspended':
        return Colors.red;
      case 'graduated':
        return Colors.blue;
      case 'inactive':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  void _showStudentDetails(Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(student.fullName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('Username', student.username),
              _buildInfoRow('Matricule', student.matriculeNumber),
              _buildInfoRow('Email', student.email),
              _buildInfoRow('Phone', student.phoneNumber),
              _buildInfoRow('Role', student.role),
              _buildInfoRow('Department', student.department),
              _buildInfoRow('Program', student.program),
              _buildInfoRow('Admission Year', '${student.admissionYear}'),
              _buildInfoRow('Current Year', '${student.currentYear}'),
              _buildInfoRow('Academic Level', student.academicLevel),
              _buildInfoRow('Enrolled Courses', '${student.enrolledCourses.length}'),
              _buildInfoRow('Attendance Rate', '${student.attendanceRate.toStringAsFixed(1)}%'),
              _buildInfoRow('Registration Date', student.registrationDate.toString().split(' ')[0]),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _editStudent(Student student) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit Student - Coming Soon')),
    );
  }

  void _showDeleteConfirmation(Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to delete ${student.fullName}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteStudent(student);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteStudent(Student student) {
    setState(() {
      _students.removeWhere((s) => s.id == student.id);
      _applyFilters();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${student.fullName} has been deleted'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _students.add(student);
              _applyFilters();
            });
          },
        ),
      ),
    );
  }
}

