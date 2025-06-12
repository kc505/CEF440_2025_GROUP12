import 'package:flutter/material.dart';
import 'package:smartcheck/utils/app_theme.dart';

class DisputeDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> dispute;

  const DisputeDetailsScreen({
    super.key,
    required this.dispute,
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispute Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      dispute['status'] == 'Approved' 
                          ? Icons.check_circle 
                          : dispute['status'] == 'Rejected'
                              ? Icons.cancel
                              : Icons.schedule,
                      color: statusColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Dispute Status: ${dispute['status']}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Dispute details card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Dispute ID', dispute['id']),
                      const Divider(),
                      _buildDetailRow('Course', '${dispute['course']}: ${dispute['courseName']}'),
                      const Divider(),
                      _buildDetailRow('Date', dispute['date']),
                      const Divider(),
                      _buildDetailRow('Submitted', dispute['submittedDate']),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Description section
              const Text(
                'Description',
                style: AppTheme.subheadingStyle,
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    dispute['description'],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Uploads section
              const Text(
                'Uploads',
                style: AppTheme.subheadingStyle,
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.attach_file,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'medical_certificate.pdf',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () {
                          // TODO: Implement file download
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // Action buttons
              if (dispute['status'] == 'Pending') ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _showCancelDialog(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppTheme.errorColor),
                          foregroundColor: AppTheme.errorColor,
                        ),
                        child: const Text('Cancel Dispute'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Navigate to edit dispute screen
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Edit Dispute'),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Back to Disputes'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Dispute'),
          content: const Text('Are you sure you want to cancel this dispute? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Implement cancel dispute API call
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Dispute cancelled successfully'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              },
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );
  }
}
