import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:your_app/services/notification_service.dart';

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

class MockLocalNotifications extends Mock
    implements FlutterLocalNotificationsPlugin {}

void main() {
  late NotificationService notificationService;
  late MockFirebaseMessaging mockFcm;
  late MockLocalNotifications mockLocal;

  setUp(() {
    mockFcm = MockFirebaseMessaging();
    mockLocal = MockLocalNotifications();
    notificationService = NotificationService();
    // Inject mocks
  });

  group('NotificationService Tests', () {
    test('initialization should request permissions and get token', () async {
      // Arrange
      when(mockFcm.requestPermission())
          .thenAnswer((_) async => const NotificationSettings());
      when(mockFcm.getToken()).thenAnswer((_) async => 'test_token');

      // Act
      await notificationService.initialize();

      // Assert
      verify(mockFcm.requestPermission()).called(1);
      verify(mockFcm.getToken()).called(1);
    });

    test('should show local notification for foreground message', () async {
      // Arrange
      final mockMessage = RemoteMessage(
        notification: const RemoteNotification(
          title: 'Test Title',
          body: 'Test Body',
        ),
      );

      // Act
      await notificationService.handleForegroundMessage(mockMessage);

      // Assert
      verify(mockLocal.show(
        any,
        'Test Title',
        'Test Body',
        any,
      )).called(1);
    });
  });
}
