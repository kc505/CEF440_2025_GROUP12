import 'package:flutter/material.dart';
import 'package:smartcheck/screens/dispute/dispute_form_screen.dart';
import 'package:smartcheck/screens/dispute/dispute_details_screen.dart';
import 'package:smartcheck/utils/app_theme.dart';

class DisputeScreen extends StatefulWidget {
  const DisputeScreen({super.key});

  @override
  State<DisputeScreen> createState() => _DisputeScreenState();
}

class _DisputeScreenState extends State<DisputeScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _disputes = [];

  @override
  void initState() {
    super.initState();
    _loadDisputes();
  }

  // Simulated data loading
  Future<void> _loadDisputes() async {
    // TODO: Replace with actual API call to fetch disputes
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _disputes = [
          {
            'id': '12345678',
            'course': 'CEF472',
            'courseName': 'Human Computer Interface',
            'date': 'Dec 2, 2024',
            'status': 'Pending',
            'description': 'I had an accident and was admitted in the hospital. I got marked absent despite informing the course delegate i can\'t be in class.',
            'submittedDate': 'Dec 3, 2024',
          },
          {
            'id': '12345679',
            'course': 'EEF470',
            'courseName': 'Feedback Systems Laboratory',
            'date': 'Nov 28, 2024',
            'status': 'Approved',
            'description': 'System error during attendance submission.',
            'submittedDate': 'Nov 29, 2024',
          },
          {
            'id': '12345680',
            'course': 'CEF440',
            'courseName': 'Internet Programming',
            'date': 'Nov 25, 2024',
            'status': 'Rejected',
            'description': 'Late arrival to class.',
            'submittedDate': 'Nov 26, 2024',
          },
        ];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadDisputes,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Disputes',
                            style: AppTheme.headingStyle,
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DisputeFormScreen(),
                                ),
                              ).then((_) => _loadDisputes());
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('New Dispute'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Dispute statistics
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Total',
                              _disputes.length.toString(),
                              AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Pending',
                              _disputes.where((d) => d['status'] == 'Pending').length.toString(),
                              Colors.amber,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Approved',
                              _disputes.where((d) => d['status'] == 'Approved').length.toString(),
                              AppTheme.successColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Rejected',
                              _disputes.where((d) => d['status'] == 'Rejected').length.toString(),
                              AppTheme.errorColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Disputes list
                      if (_disputes.isEmpty)
                        Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 40),
                              Icon(
                                Icons.report_problem_outlined,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No disputes found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Create a new dispute if you have any attendance issues',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _disputes.length,
                          itemBuilder: (context, index) {
                            final dispute = _disputes[index];
                            return DisputeCard(
                              dispute: dispute,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DisputeDetailsScreen(dispute: dispute),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DisputeFormScreen(),
            ),
          ).then((_) => _loadDisputes());
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DisputeCard extends StatelessWidget {
  final Map<String, dynamic> dispute;
  final VoidCallback onTap;

  const DisputeCard({
    super.key,
    required this.dispute,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (dispute['status']) {
      case 'Approved':
        statusColor = AppTheme.successColor;
        break;
      case 'Rejected':
        statusColor = AppTheme.errorColor;
        break;
      default:
        statusColor = Colors.amber;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${dispute['course']}: ${dispute['courseName']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      dispute['status'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Dispute ID: ${dispute['id']}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Date: ${dispute['date']}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dispute['description'],
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Submitted: ${dispute['submittedDate']}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
