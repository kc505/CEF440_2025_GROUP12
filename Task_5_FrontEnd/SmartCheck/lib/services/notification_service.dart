import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize notifications
  static Future<void> initialize() async {
    final NotificationService notificationService = NotificationService();
    await notificationService._initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize the plugin
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _onNotificationTapped(response.payload);
      },
    );

    // Request permissions
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  static void _onNotificationTapped(String? payload) {
    if (payload != null) {
      debugPrint('Notification tapped with payload: $payload');
      // Handle notification tap based on payload
      _handleNotificationTap(payload);
    }
  }

  static void _handleNotificationTap(String payload) {
    // Parse payload and navigate accordingly
    try {
      final parts = payload.split('|');
      if (parts.length >= 2) {
        final type = parts[0];
        final data = parts[1];
        
        switch (type) {
          case 'session_created':
            debugPrint('Navigate to session: $data');
            break;
          case 'attendance_reminder':
            debugPrint('Navigate to attendance for: $data');
            break;
          case 'session_ended':
            debugPrint('Navigate to session results: $data');
            break;
          default:
            debugPrint('Unknown notification type: $type');
        }
      }
    } catch (e) {
      debugPrint('Error handling notification tap: $e');
    }
  }

  // Send notification to students when session is created
  Future<bool> sendSessionCreatedNotification({
    required String sessionId,
    required String courseCode,
    required String courseName,
    required String venue,
    required DateTime date,
    required String startTime,
    required String endTime,
    required List<String> studentIds,
  }) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'session_channel',
        'Session Notifications',
        channelDescription: 'Notifications for new sessions',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF2196F3),
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        'New Session Created',
        '$courseCode - $courseName\n📍 $venue\n🕐 $startTime - $endTime',
        platformChannelSpecifics,
        payload: 'session_created|$sessionId',
      );

      debugPrint('Session notification sent');
      debugPrint('Session: $courseCode - $courseName');
      debugPrint('Venue: $venue');
      debugPrint('Time: $startTime - $endTime');
      
      return true;
    } catch (e) {
      debugPrint('Error sending notification: $e');
      return false;
    }
  }

  // Send notification when session status changes
  Future<bool> sendSessionStatusNotification({
    required String sessionId,
    required String courseCode,
    required String courseName,
    required String oldStatus,
    required String newStatus,
    required List<String> studentIds,
  }) async {
    try {
      String statusIcon = _getStatusIcon(newStatus);
      
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'status_channel',
        'Status Updates',
        channelDescription: 'Session status update notifications',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF4CAF50),
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        'Session Status Updated',
        '$statusIcon $courseCode - $courseName\nStatus: $newStatus',
        platformChannelSpecifics,
        payload: 'status_update|$sessionId',
      );
      
      debugPrint('Status update sent');
      debugPrint('$courseCode: $oldStatus → $newStatus');
      
      return true;
    } catch (e) {
      debugPrint('Error sending status notification: $e');
      return false;
    }
  }

  // Send attendance reminder
  Future<bool> sendAttendanceReminder({
    required String sessionId,
    required String courseCode,
    required List<String> studentIds,
  }) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'reminder_channel',
        'Attendance Reminders',
        channelDescription: 'Attendance reminder notifications',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFFFF9800),
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        '⏰ Attendance Reminder',
        'Don\'t forget to mark your attendance for $courseCode',
        platformChannelSpecifics,
        payload: 'attendance_reminder|$sessionId',
      );
      
      debugPrint('Attendance reminder sent for $courseCode');
      
      return true;
    } catch (e) {
      debugPrint('Error sending reminder: $e');
      return false;
    }
  }

  // Send notification when session ends
  Future<bool> sendSessionEndedNotification({
    required String sessionId,
    required String courseCode,
    required int attendanceCount,
    required int totalStudents,
  }) async {
    try {
      double attendanceRate = (attendanceCount / totalStudents) * 100;
      String rateIcon = attendanceRate >= 80 ? '✅' : attendanceRate >= 60 ? '⚠️' : '❌';
      
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'session_end_channel',
        'Session Completed',
        channelDescription: 'Session completion notifications',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF9C27B0),
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        '$rateIcon Session Ended',
        '$courseCode session completed\nAttendance: $attendanceCount/$totalStudents (${attendanceRate.toStringAsFixed(1)}%)',
        platformChannelSpecifics,
        payload: 'session_ended|$sessionId',
      );
      
      debugPrint('Session ended notification sent for $courseCode');
      debugPrint('Attendance: $attendanceCount/$totalStudents (${attendanceRate.toStringAsFixed(1)}%)');
      
      return true;
    } catch (e) {
      debugPrint('Error sending session ended notification: $e');
      return false;
    }
  }

  // Send custom notification
  Future<bool> sendCustomNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'general_channel',
        'General Notifications',
        channelDescription: 'General app notifications',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        platformChannelSpecifics,
        payload: payload ?? 'custom|general',
      );
      
      return true;
    } catch (e) {
      debugPrint('Error sending custom notification: $e');
      return false;
    }
  }

  // Helper method to get status icon
  String _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'ongoing':
        return '🟢';
      case 'completed':
      case 'ended':
        return '✅';
      case 'cancelled':
        return '❌';
      case 'scheduled':
        return '📅';
      default:
        return '📋';
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}
