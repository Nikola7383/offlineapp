import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:secure_event_app/core/notifications/notification_service.dart';
import 'package:secure_event_app/core/logging/logger_service.dart';
import 'package:secure_event_app/core/models/message.dart';

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockLogger extends Mock implements LoggerService {}

void main() {
  late NotificationService notificationService;
  late MockLogger mockLogger;

  setUp(() {
    mockLogger = MockLogger();
    notificationService = NotificationService(logger: mockLogger);
  });

  group('NotificationService Tests', () {
    test('should initialize successfully', () async {
      // Act
      await notificationService.initialize();

      // Assert
      verify(mockLogger.info(any)).called(greaterThan(0));
    });

    test('should show message notification', () async {
      // Arrange
      final message = Message(
        id: '1',
        content: 'Test message',
        senderId: 'user1',
        timestamp: DateTime.now(),
      );

      // Act
      await notificationService.showMessageNotification(message);

      // Assert
      verify(mockLogger.info(any)).called(greaterThan(0));
    });
  });
}
