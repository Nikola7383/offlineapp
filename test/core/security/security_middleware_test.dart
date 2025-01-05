import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/security/security_middleware.dart';
import 'package:secure_event_app/core/logging/logger_service.dart';

class MockLoggerService extends Mock implements LoggerService {}

void main() {
  late SecurityMiddleware security;
  late MockLoggerService mockLogger;

  setUp(() {
    mockLogger = MockLoggerService();
    security = SecurityMiddleware(logger: mockLogger);
  });

  group('SecurityMiddleware Tests', () {
    test('validates file transfer correctly', () {
      expect(
        security.validateFileTransfer('test.jpg', 1024 * 1024),
        isTrue,
      );
      expect(
        security.validateFileTransfer('test.exe', 1024),
        isFalse,
      );
      expect(
        security.validateFileTransfer('test.jpg', 20 * 1024 * 1024),
        isFalse,
      );
    });

    test('rate limiting works correctly', () {
      const deviceId = 'test_device';
      const action = 'message';

      // Prvi pokušaji treba da prođu
      for (var i = 0; i < 20; i++) {
        expect(security.validateRequest(deviceId, action), isTrue);
      }

      // Sledeći pokušaj treba da bude blokiran
      expect(security.validateRequest(deviceId, action), isFalse);
    });

    test('blacklist functionality works', () {
      const deviceId = 'bad_device';

      // Pre blacklist-a
      expect(security.validateRequest(deviceId, 'message'), isTrue);

      // Nakon blacklist-a
      security.blacklistDevice(deviceId);
      expect(security.validateRequest(deviceId, 'message'), isFalse);

      // Nakon uklanjanja sa blacklist-a
      security.removeFromBlacklist(deviceId);
      expect(security.validateRequest(deviceId, 'message'), isTrue);
    });
  });
}
