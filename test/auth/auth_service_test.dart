import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:secure_event_app/core/auth/auth_service.dart';
import 'package:secure_event_app/core/logging/logger_service.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

class MockLogger extends Mock implements LoggerService {}

void main() {
  late AuthService authService;
  late MockSecureStorage mockStorage;
  late MockLogger mockLogger;

  setUp(() {
    mockStorage = MockSecureStorage();
    mockLogger = MockLogger();
    authService = AuthService(logger: mockLogger);
  });

  group('AuthService Tests', () {
    test('should successfully login with valid credentials', () async {
      // Act
      final result = await authService.login('test', 'password123');

      // Assert
      expect(result.success, isTrue);
      expect(result.user, isNotNull);
      expect(result.user?.username, equals('test'));
    });

    test('should fail login with invalid credentials', () async {
      // Act
      final result = await authService.login('wrong', 'invalid');

      // Assert
      expect(result.success, isFalse);
      expect(result.error, isNotNull);
    });

    test('should successfully logout', () async {
      // Arrange
      await authService.login('test', 'password123');

      // Act
      final result = await authService.logout();

      // Assert
      expect(result, isTrue);
      expect(authService.currentUser, isNull);
    });
  });
}
