import 'package:flutter/material.dart';
import 'package:smartcheck/utils/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> _filteredNotifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Simulated data loading
  Future<void> _loadNotifications() async {
    // TODO: Replace with actual API call to fetch notifications
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _notifications = [
          {
            'id': '1',
            'title': 'Dispute Pending',
            'description': 'Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do eiusmod tempor incididunt ut lab ore et dolore magna.',
            'time': '1 day ago',
            'type': 'dispute',
            'isRead': false,
          },
          {
            'id': '2',
            'title': 'Attendance Confirmation',
            'description': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna.',
            'time': '1 hour',
            'type': 'attendance',
            'isRead': false,
          },
          {
            'id': '3',
            'title': 'Attendance Confirmation',
            'description': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna.',
            'time': '1 hour',
            'type': 'attendance',
            'isRead': true,
          },
          {
            'id': '4',
            'title': 'Dispute Approved',
            'description': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna.',
            'time': '20 minutes',
            'type': 'dispute',
            'isRead': false,
          },
          {
            'id': '5',
            'title': 'Facial recognition successful',
            'description': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna.',
            'time': '20 minutes',
            'type': 'face_recognition',
            'isRead': true,
          },
          {
            'id': '6',
            'title': 'Facial recognition successful',
            'description': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna.',
            'time': '2 days ago',
            'type': 'face_recognition',
            'isRead': true,
          },
        ];
        _filteredNotifications = _notifications;
        _isLoading = false;
      });
    }
  }

  void _filterNotifications(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredNotifications = _notifications;
      } else {
        _filteredNotifications = _notifications.where((notification) {
          return notification['title'].toLowerCase().contains(query.toLowerCase()) ||
                 notification['description'].toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _markAsRead(String notificationId) {
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        _notifications[index]['isRead'] = true;
      }
      _filterNotifications(_searchController.text);
    });
    
    // TODO: Implement API call to mark notification as read
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
      _filterNotifications(_searchController.text);
    });
    
    // TODO: Implement API call to mark all notifications as read
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: _markAllAsRead,
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search notifications...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: _filterNotifications,
                  ),
                ),
                
                // Notifications list
                Expanded(
                  child: _filteredNotifications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.notifications_none,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No notifications found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadNotifications,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: _filteredNotifications.length,
                            itemBuilder: (context, index) {
                              final notification = _filteredNotifications[index];
                              return NotificationCard(
                                notification: notification,
                                onTap: () => _markAsRead(notification['id']),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor;
    
    switch (notification['type']) {
      case 'dispute':
        iconData = Icons.report_problem;
        iconColor = Colors.amber;
        break;
      case 'attendance':
        iconData = Icons.check_circle;
        iconColor = AppTheme.successColor;
        break;
      case 'face_recognition':
        iconData = Icons.face;
        iconColor = AppTheme.primaryColor;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = AppTheme.primaryColor;
    }

    return Card(
      elevation: notification['isRead'] ? 1 : 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: notification['isRead'] ? null : AppTheme.primaryColor.withOpacity(0.05),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: notification['isRead'] 
                                    ? FontWeight.w500 
                                    : FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!notification['isRead'])
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notification['description'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notification['time'],
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondaryColor.withOpacity(0.7),
                        ),
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
}
