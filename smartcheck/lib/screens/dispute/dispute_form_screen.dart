import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smartcheck/utils/app_theme.dart';
import 'package:smartcheck/widgets/custom_button.dart';
import 'package:smartcheck/widgets/custom_text_field.dart';
import 'package:smartcheck/services/file_service.dart';

class DisputeFormScreen extends StatefulWidget {
  const DisputeFormScreen({super.key});

  @override
  State<DisputeFormScreen> createState() => _DisputeFormScreenState();
}

class _DisputeFormScreenState extends State<DisputeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  
  String? _selectedCourse;
  String? _selectedDisputeType;
  File? _selectedFile;
  bool _isLoading = false;

  final List<String> _courses = [
    'CEF472: Human Computer Interface',
    'EEF470: Feedback Systems Laboratory',
    'EEF470: Feedback Systems Laboratory',
    'CEF440: Internet Programming',
    'CEF450: Cloud Computing and SOA',
  ];

  final List<String> _disputeTypes = [
    'Attendance Marking Error',
    'System Technical Issue',
    'Medical Emergency',
    'Family Emergency',
    'Transportation Issue',
    'Other',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitDispute() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // TODO: Implement actual API call to submit dispute
        // This would include uploading the file if selected
        await Future.delayed(const Duration(seconds: 2));
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dispute submitted successfully!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.pop(context);
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

  Future<void> _pickFile() async {
    try {
      final File? file = await FileService.pickDocumentFile();
      
      if (file != null) {
        setState(() {
          _selectedFile = file;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File selected: ${FileService.getFileName(file.path)}'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting file: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispute Form'),
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
                  const Text(
                    'Fill in the form to create a dispute',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Course selection
                  const Text(
                    'Select Course',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCourse,
                    decoration: AppTheme.inputDecoration('Select Course'),
                    items: _courses.map((course) {
                      return DropdownMenuItem(
                        value: course,
                        child: Text(course),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCourse = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a course';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Dispute type selection
                  const Text(
                    'Choose Dispute',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedDisputeType,
                    decoration: AppTheme.inputDecoration('Choose Dispute'),
                    items: _disputeTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDisputeType = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a dispute type';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Description field
                  const Text(
                    'Brief Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: AppTheme.inputDecoration(
                      'Brief Description',
                      hint: 'Describe your issue in detail...',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please provide a description';
                      }
                      if (value.length < 10) {
                        return 'Description must be at least 10 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // File attachment
                  const Text(
                    'File Attachment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickFile,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.dividerColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.attach_file,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedFile != null 
                                  ? FileService.getFileName(_selectedFile!.path)
                                  : 'Choose File',
                              style: TextStyle(
                                color: _selectedFile != null 
                                    ? AppTheme.textPrimaryColor 
                                    : AppTheme.textSecondaryColor,
                              ),
                            ),
                          ),
                          if (_selectedFile != null)
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: _removeFile,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // File info
                  if (_selectedFile != null) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppTheme.successColor,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'File Selected: ${FileService.getFileSize(_selectedFile!)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.successColor,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      'No File Chosen (Optional)',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 8),
                  Text(
                    'Supported formats: PDF, DOC, DOCX, TXT, JPG, JPEG, PNG',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Submit button
                  CustomButton(
                    text: 'Continue',
                    onPressed: _submitDispute,
                    isLoading: _isLoading,
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
