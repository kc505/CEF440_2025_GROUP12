import 'package:flutter/material.dart';
import 'package:smartcheck/utils/app_theme.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<FAQItem> _filteredFAQs = [];
  
  final List<FAQItem> _allFAQs = [
    FAQItem(
      question: "How do I join a class?",
      answer: "To join a class, tap the '+' button on the home screen and enter the class code provided by your instructor. The class code is usually a combination of letters and numbers.",
    ),
    FAQItem(
      question: "What should I do if I forget my password?",
      answer: "On the login screen, tap 'Forgot Password' and enter your email address. You'll receive an email with instructions to reset your password.",
    ),
    FAQItem(
      question: "How do I submit an assignment?",
      answer: "Navigate to the specific course, find the assignment, and tap on it. Follow the instructions to upload your work or complete the required tasks.",
    ),
    FAQItem(
      question: "Can I access my courses offline?",
      answer: "Some course materials may be available offline after they've been downloaded. However, submitting assignments and accessing live features requires an internet connection.",
    ),
    FAQItem(
      question: "How do I change my profile information?",
      answer: "Go to Profile > Student Details, then tap the edit icon in the top right corner. Make your changes and tap save.",
    ),
    FAQItem(
      question: "What happens if I miss a class?",
      answer: "Missed classes will be marked in your attendance record. Contact your instructor for any makeup opportunities or materials you may have missed.",
    ),
    FAQItem(
      question: "How do I enable/disable notifications?",
      answer: "Go to Profile > Settings > Notifications. You can toggle different types of notifications on or off according to your preferences.",
    ),
    FAQItem(
      question: "Can I drop a course after joining?",
      answer: "You can leave a course by going to the course details and selecting 'Leave Course'. However, check with your instructor about any academic implications.",
    ),
    FAQItem(
      question: "How do I contact technical support?",
      answer: "For technical issues, you can reach out through the app's feedback system or contact support at support@smartcheck.edu",
    ),
    FAQItem(
      question: "Is my data secure on SmartCheck?",
      answer: "Yes, we use industry-standard encryption and security measures to protect your personal and academic data. See our Privacy Policy for more details.",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _filteredFAQs = _allFAQs;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterFAQs(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFAQs = _allFAQs;
      } else {
        _filteredFAQs = _allFAQs.where((faq) =>
          faq.question.toLowerCase().contains(query.toLowerCase()) ||
          faq.answer.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search FAQs...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterFAQs('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
              ),
              onChanged: _filterFAQs,
            ),
          ),
          
          // FAQ List
          Expanded(
            child: _filteredFAQs.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No FAQs found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Try adjusting your search terms',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _filteredFAQs.length,
                    itemBuilder: (context, index) {
                      return _buildFAQItem(_filteredFAQs[index]);
                    },
                  ),
          ),
          
          // Contact support
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.help_center,
                      size: 48,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Still need help?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Contact our support team',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Handle contact support
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Opening support chat...'),
                            backgroundColor: AppTheme.primaryColor,
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat),
                      label: const Text('Contact Support'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(FAQItem faq) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          faq.question,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              faq.answer,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
                height: 1.5,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({
    required this.question,
    required this.answer,
  });
}