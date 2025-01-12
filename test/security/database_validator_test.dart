import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../../lib/security/database/database_validator.dart';
import '../../lib/core/interfaces/database_validator_interface.dart';
import '../mocks/security_mocks.mocks.dart';

void main() {
  late MockILoggerService mockLogger;
  late DatabaseValidator validator;

  setUp(() {
    mockLogger = MockILoggerService();
    validator = DatabaseValidator(mockLogger);
  });

  test('initialize() should set isInitialized to true', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    when(mockLogger.warning(any)).thenAnswer((_) => Future.value());

    // Act
    await validator.initialize();

    // Assert
    expect(validator.isInitialized, true);
    verify(mockLogger.info('Initializing DatabaseValidator')).called(1);
    verify(mockLogger.info('DatabaseValidator initialized')).called(1);
  });

  test('initialize() should not initialize twice', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    when(mockLogger.warning(any)).thenAnswer((_) => Future.value());

    // Act
    await validator.initialize();
    await validator.initialize();

    // Assert
    verify(mockLogger.warning('DatabaseValidator already initialized'))
        .called(1);
  });

  test('validateDatabase() should fail if not initialized', () async {
    // Arrange
    when(mockLogger.error(any)).thenAnswer((_) => Future.value());

    // Act
    final result = await validator.validateDatabase();

    // Assert
    expect(result, false);
    verify(mockLogger.error('DatabaseValidator not initialized')).called(1);
  });

  test('validateDatabase() should emit validation events', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    await validator.initialize();

    // Act & Assert
    expectLater(
      validator.validationEvents,
      emitsInOrder([
        predicate<ValidationEvent>((event) =>
            event.type == ValidationEventType.validationStarted &&
            event.data.containsKey('timestamp')),
        predicate<ValidationEvent>((event) =>
            event.type == ValidationEventType.validationCompleted &&
            event.data['result'] == 'success'),
      ]),
    );

    await validator.validateDatabase();
  });

  test('validateDatabase() should not allow concurrent validations', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    when(mockLogger.warning(any)).thenAnswer((_) => Future.value());
    await validator.initialize();

    // Act
    final firstValidation = validator.validateDatabase();
    final secondValidation = await validator.validateDatabase();

    // Assert
    expect(secondValidation, false);
    verify(mockLogger.warning('Database validation already in progress'))
        .called(1);
    await firstValidation; // čekamo da se prva validacija završi
  });

  test('generateReport() should include issues when initialized', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    await validator.initialize();

    // Act
    final report = await validator.generateReport();

    // Assert
    expect(report.isValid, true);
    expect(report.issues.length, 1);
    expect(report.issues.first.severity, ValidationSeverity.low);
    expect(report.metadata.containsKey('lastCheck'), true);
    expect(report.metadata.containsKey('checkDuration'), true);
  });

  test('generateReport() should return error report when not initialized',
      () async {
    // Arrange
    when(mockLogger.error(any)).thenAnswer((_) => Future.value());

    // Act
    final report = await validator.generateReport();

    // Assert
    expect(report.isValid, false);
    expect(report.issues.isEmpty, true);
    expect(report.metadata['error'], 'Validator not initialized');
  });

  test('dispose() should cleanup resources', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    await validator.initialize();

    // Act
    await validator.dispose();

    // Assert
    expect(validator.isInitialized, false);
    verify(mockLogger.info('DatabaseValidator disposed')).called(1);
  });
}
