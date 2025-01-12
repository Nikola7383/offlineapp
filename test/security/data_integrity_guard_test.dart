import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../../lib/security/integrity/data_integrity_guard.dart';
import '../../lib/core/interfaces/data_integrity_interface.dart';
import '../mocks/security_mocks.mocks.dart';

void main() {
  late MockILoggerService mockLogger;
  late DataIntegrityGuard guard;

  setUp(() {
    mockLogger = MockILoggerService();
    guard = DataIntegrityGuard(mockLogger);
  });

  test('initialize() should set isInitialized to true', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    when(mockLogger.warning(any)).thenAnswer((_) => Future.value());

    // Act
    await guard.initialize();

    // Assert
    expect(guard.isInitialized, true);
    verify(mockLogger.info('Initializing DataIntegrityGuard')).called(1);
    verify(mockLogger.info('DataIntegrityGuard initialized')).called(1);
  });

  test('initialize() should not initialize twice', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    when(mockLogger.warning(any)).thenAnswer((_) => Future.value());

    // Act
    await guard.initialize();
    await guard.initialize();

    // Assert
    verify(mockLogger.warning('DataIntegrityGuard already initialized'))
        .called(1);
  });

  test('protectData() should fail if not initialized', () async {
    // Arrange
    when(mockLogger.error(any)).thenAnswer((_) => Future.value());

    // Act
    await guard.protectData();

    // Assert
    verify(mockLogger.error('DataIntegrityGuard not initialized')).called(1);
  });

  test('protectData() should emit protection event', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    await guard.initialize();

    // Act & Assert
    expectLater(
      guard.integrityEvents,
      emits(
        predicate<IntegrityEvent>((event) =>
            event.type == IntegrityEventType.protectionApplied &&
            event.data.containsKey('timestamp')),
      ),
    );

    await guard.protectData();
  });

  test('verifyIntegrity() should return true when initialized', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    await guard.initialize();

    // Act
    final result = await guard.verifyIntegrity();

    // Assert
    expect(result, true);
  });

  test('verifyIntegrity() should emit check events', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    await guard.initialize();

    // Act & Assert
    expectLater(
      guard.integrityEvents,
      emitsInOrder([
        predicate<IntegrityEvent>(
            (event) => event.type == IntegrityEventType.checkStarted),
        predicate<IntegrityEvent>(
            (event) => event.type == IntegrityEventType.checkCompleted),
      ]),
    );

    await guard.verifyIntegrity();
  });

  test('generateReport() should include issues when initialized', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    await guard.initialize();

    // Act
    final report = await guard.generateReport();

    // Assert
    expect(report.isValid, true);
    expect(report.issues.length, 1);
    expect(report.issues.first.severity, IssueSeverity.low);
    expect(report.metadata.containsKey('lastCheck'), true);
    expect(report.metadata.containsKey('checkDuration'), true);
  });

  test('generateReport() should return error report when not initialized',
      () async {
    // Arrange
    when(mockLogger.error(any)).thenAnswer((_) => Future.value());

    // Act
    final report = await guard.generateReport();

    // Assert
    expect(report.isValid, false);
    expect(report.issues.isEmpty, true);
    expect(report.metadata['error'], 'Guard not initialized');
  });

  test('dispose() should cleanup resources', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    await guard.initialize();

    // Act
    await guard.dispose();

    // Assert
    expect(guard.isInitialized, false);
    verify(mockLogger.info('DataIntegrityGuard disposed')).called(1);
  });
}
