import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../logging/logger_service.dart';
import '../models/message.dart';

class NotificationService {
  final LoggerService logger;
  final FlutterLocalNotificationsPlugin _notifications;

  NotificationService({
    required this.logger,
  }) : _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _handleNotificationTap,
      );
    } catch (e) {
      logger.error('Failed to initialize notifications', e);
    }
  }

  Future<void> showMessageNotification(Message message) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'messages_channel',
        'Messages',
        channelDescription: 'Notifications for new messages',
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails();

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        message.hashCode,
        'New Message',
        message.content,
        details,
      );
    } catch (e) {
      logger.error('Failed to show notification', e);
    }
  }

  void _handleNotificationTap(NotificationResponse response) {
    // TODO: Implement navigation to specific message
    logger.info('Notification tapped: ${response.payload}');
  }
}
