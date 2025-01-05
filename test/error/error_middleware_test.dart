import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/error/error_middleware.dart';
import 'package:secure_event_app/core/logging/logger_service.dart';

class MockLoggerService extends Mock implements LoggerService {}

void main() {
  late ErrorMiddleware errorMiddleware;
  late MockLoggerService mockLogger;
  late List<String> fatalErrors;
  late List<String> userErrors;

  setUp(() {
    mockLogger = MockLoggerService();
    fatalErrors = [];
    userErrors = [];

    errorMiddleware = ErrorMiddleware(
      logger: mockLogger,
      onFatalError: (message) => fatalErrors.add(message),
      onUserError: (message) => userErrors.add(message),
    );
  });

  group('ErrorMiddleware Tests', () {
    test('handles AppException with fatal severity', () {
      // Arrange
      final exception = AppException(
        message: 'Test fatal error',
        severity: ErrorSeverity.fatal,
      );

      // Act
      errorMiddleware._handleError(exception, StackTrace.empty);

      // Assert
      verify(mockLogger.error(any, any)).called(1);
      expect(fatalErrors.length, 1);
      expect(fatalErrors.first, exception.userMessage);
    });

    test('handles AppException with error severity', () {
      // Arrange
      final exception = AppException(
        message: 'Test error',
        severity: ErrorSeverity.error,
      );

      // Act
      errorMiddleware._handleError(exception, StackTrace.empty);

      // Assert
      verify(mockLogger.error(any, any)).called(1);
      expect(userErrors.length, 1);
      expect(userErrors.first, exception.userMessage);
    });

    test('handles system errors', () {
      // Arrange
      final error = Exception('Test system error');

      // Act
      errorMiddleware._handleError(error, StackTrace.empty);

      // Assert
      verify(mockLogger.error(any, any, any)).called(1);
      expect(fatalErrors.length, 1);
    });

    test('runGuarded executes successfully', () async {
      // Arrange
      int result = 0;

      // Act
      await errorMiddleware.runGuarded(() async {
        result = 42;
        return;
      });

      // Assert
      expect(result, 42);
    });

    test('runGuarded handles errors', () async {
      // Act & Assert
      expect(
        () => errorMiddleware.runGuarded(() async {
          throw AppException(message: 'Test error');
        }),
        throwsA(isA<AppException>()),
      );
    });
  });
}
