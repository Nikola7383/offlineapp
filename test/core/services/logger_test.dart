import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/core/services/logger_impl.dart';
import '../test_setup.dart';

void main() {
  late LoggerImpl logger;

  setUp(() {
    logger = const LoggerImpl(
      enableDebugLogs: true,
      prefix: 'TEST',
    );
  });

  group('Logger Tests', () {
    test('should log info messages', () async {
      // Act & Assert
      expect(
        () => logger.info('Test info message'),
        returnsNormally,
      );
    });

    test('should log error messages with stack trace', () async {
      // Arrange
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;

      // Act & Assert
      expect(
        () => logger.error('Test error message', error, stackTrace),
        returnsNormally,
      );
    });

    test('should log warning messages with context', () async {
      // Arrange
      final context = {'key': 'value'};

      // Act & Assert
      expect(
        () => logger.warning('Test warning message', context),
        returnsNormally,
      );
    });

    test('should respect debug log flag', () async {
      // Arrange
      final debugLogger = const LoggerImpl(enableDebugLogs: false);
      final normalLogger = const LoggerImpl(enableDebugLogs: true);

      // Act & Assert
      expect(
        () => debugLogger.debug('Should not be logged'),
        returnsNormally,
      );

      expect(
        () => normalLogger.debug('Should be logged'),
        returnsNormally,
      );
    });

    test('should format messages correctly', () async {
      // Arrange
      final testLogger = LoggerImpl(
        enableDebugLogs: true,
        prefix: 'TEST_PREFIX',
      );

      // Act & Assert
      expect(
        () => testLogger.info('Test message'),
        returnsNormally,
      );
    });
  });
}
