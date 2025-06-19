import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../models/course.dart';
import '../../models/student.dart';

class CourseStudentsScreen extends StatefulWidget {
  final Course course;
  
  const CourseStudentsScreen({Key? key, required this.course}) : super(key: key);

  @override
  State<CourseStudentsScreen> createState() => _CourseStudentsScreenState();
}

class _CourseStudentsScreenState extends State<CourseStudentsScreen> {
  List<Student> _students = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data using the new student structure
      _students = [
        Student(
          id: '1',
          username: 'mekole.ash',
          password: 'password123',
          firstName: 'Mekole',
          lastName: 'Ashley',
          email: 'mekoleash@gmail.com',
          role: 'Student',
          phoneNumber: '677030466',
          registrationDate: DateTime(2023, 9, 1),
          profileImageURL: null,
          matriculeNumber: 'CE/2023/001',
          department: 'Computer Engineering',
          program: 'BEng Computer Engineering',
          admissionYear: 2023,
          enrolledCourses: [widget.course.code, 'CE102', 'MAT101'],
          academicStatus: 'Active',
          gpa: 3.8,
          totalCredits: 45,
        ),
        Student(
          id: '2',
          username: 'john.doe',
          password: 'password123',
          firstName: 'John',
          lastName: 'Doe',
          email: 'john.doe@gmail.com',
          role: 'Student',
          phoneNumber: '677030467',
          registrationDate: DateTime(2023, 9, 1),
          profileImageURL: null,
          matriculeNumber: 'CE/2023/002',
          department: 'Computer Engineering',
          program: 'BEng Computer Engineering',
          admissionYear: 2023,
          enrolledCourses: [widget.course.code, 'CE103', 'MAT102'],
          academicStatus: 'Active',
          gpa: 3.2,
          totalCredits: 42,
        ),
        Student(
          id: '3',
          username: 'jane.smith',
          password: 'password123',
          firstName: 'Jane',
          lastName: 'Smith',
          email: 'jane.smith@gmail.com',
          role: 'Student',
          phoneNumber: '677030468',
          registrationDate: DateTime(2022, 9, 1),
          profileImageURL: null,
          matriculeNumber: 'CE/2022/015',
          department: 'Computer Engineering',
          program: 'BEng Computer Engineering',
          admissionYear: 2022,
          enrolledCourses: [widget.course.code, 'CE201', 'MAT201'],
          academicStatus: 'Active',
          gpa: 3.9,
          totalCredits: 90,
        ),
        Student(
          id: '4',
          username: 'mike.wilson',
          password: 'password123',
          firstName: 'Mike',
          lastName: 'Wilson',
          email: 'mike.wilson@gmail.com',
          role: 'Student',
          phoneNumber: '677030469',
          registrationDate: DateTime(2021, 9, 1),
          profileImageURL: null,
          matriculeNumber: 'CE/2021/008',
          department: 'Computer Engineering',
          program: 'BEng Computer Engineering',
          admissionYear: 2021,
          enrolledCourses: [widget.course.code, 'CE301', 'CE302'],
          academicStatus: 'Active',
          gpa: 3.5,
          totalCredits: 135,
        ),
        Student(
          id: '5',
          username: 'sarah.brown',
          password: 'password123',
          firstName: 'Sarah',
          lastName: 'Brown',
          email: 'sarah.brown@gmail.com',
          role: 'Student',
          phoneNumber: '677030470',
          registrationDate: DateTime(2020, 9, 1),
          profileImageURL: null,
          matriculeNumber: 'CE/2020/012',
          department: 'Computer Engineering',
          program: 'BEng Computer Engineering',
          admissionYear: 2020,
          enrolledCourses: [widget.course.code, 'CE401', 'CE402'],
          academicStatus: 'Active',
          gpa: 3.7,
          totalCredits: 180,
        ),
      ];
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading students: ${e.toString()}'),
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

  List<Student> get _filteredStudents {
    if (_searchQuery.isEmpty) return _students;
    
    return _students.where((student) {
      return student.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             student.matriculeNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             student.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             student.username.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('${widget.course.code} Students'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStudents,
          ),
        ],
      ),
      body: Column(
        children: [
          // Course Info Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryColor.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.course.title,
                  style: AppTheme.headingStyle.copyWith(
                    color: AppTheme.primaryColor,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total Students: ${_students.length} | Completed Sessions: ${widget.course.completedSessions}/${widget.course.totalSessions}',
                  style: AppTheme.bodyStyle.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search students by name, matricule, email, or username...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
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
                              _searchQuery.isEmpty 
                                  ? 'No students enrolled'
                                  : 'No students match your search',
                              style: AppTheme.bodyStyle.copyWith(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        student.matriculeNumber,
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
                // Attendance Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: student.attendanceColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: student.attendanceColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    '${student.attendanceRate.toInt()}%',
                    style: TextStyle(
                      color: student.attendanceColor,
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
                          'Username',
                          student.username,
                          Icons.person,
                        ),
                      ),
                      Expanded(
                        child: _buildDetailItem(
                          'Year',
                          '${student.currentYear}',
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
                          Icons.school,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Attendance Details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildAttendanceDetail(
                      'Attended',
                      '${student.attendedSessions}',
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.grey[300],
                  ),
                  Expanded(
                    child: _buildAttendanceDetail(
                      'Total',
                      '${student.totalSessions}',
                      Icons.calendar_today,
                      Colors.blue,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.grey[300],
                  ),
                  Expanded(
                    child: _buildAttendanceDetail(
                      'Missed',
                      '${student.missedSessions}',
                      Icons.cancel,
                      Colors.red,
                    ),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Student History - Coming Soon')),
                    );
                  },
                  icon: const Icon(Icons.history, size: 16),
                  label: const Text('History'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange,
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

  Widget _buildAttendanceDetail(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.bodyStyle.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: color,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTheme.bodyStyle.copyWith(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
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
              _buildInfoRow('Department', student.department),
              _buildInfoRow('Program', student.program),
              _buildInfoRow('Admission Year', '${student.admissionYear}'),
              _buildInfoRow('Current Year', '${student.currentYear}'),
              _buildInfoRow('Academic Level', student.academicLevel),
              _buildInfoRow('GPA', student.gpa?.toStringAsFixed(2) ?? 'N/A'),
              _buildInfoRow('Total Credits', '${student.totalCredits}'),
              _buildInfoRow('Status', student.academicStatus),
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
}
