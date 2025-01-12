import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../../lib/security/storage/storage_protector.dart';
import '../../lib/core/interfaces/storage_protection_interface.dart';
import '../mocks/security_mocks.mocks.dart';

void main() {
  late MockILoggerService mockLogger;
  late StorageProtector protector;

  setUp(() {
    mockLogger = MockILoggerService();
    protector = StorageProtector(mockLogger);
  });

  test('initialize() should set isInitialized to true', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    when(mockLogger.warning(any)).thenAnswer((_) => Future.value());

    // Act
    await protector.initialize();

    // Assert
    expect(protector.isInitialized, true);
    verify(mockLogger.info('Initializing StorageProtector')).called(1);
    verify(mockLogger.info('StorageProtector initialized')).called(1);
  });

  test('initialize() should not initialize twice', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    when(mockLogger.warning(any)).thenAnswer((_) => Future.value());

    // Act
    await protector.initialize();
    await protector.initialize();

    // Assert
    verify(mockLogger.warning('StorageProtector already initialized'))
        .called(1);
  });

  test('secureCriticalData() should fail if not initialized', () async {
    // Arrange
    when(mockLogger.error(any)).thenAnswer((_) => Future.value());

    // Act
    await protector.secureCriticalData();

    // Assert
    verify(mockLogger.error('StorageProtector not initialized')).called(1);
  });

  test('secureCriticalData() should emit protection events', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    await protector.initialize();

    // Act & Assert
    expectLater(
      protector.protectionEvents,
      emitsInOrder([
        predicate<ProtectionEvent>((event) =>
            event.type == ProtectionEventType.protectionStarted &&
            event.data.containsKey('timestamp')),
        predicate<ProtectionEvent>((event) =>
            event.type == ProtectionEventType.protectionCompleted &&
            event.data['result'] == 'success'),
      ]),
    );

    await protector.secureCriticalData();
  });

  test('verifyProtection() should return true when initialized', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    await protector.initialize();

    // Act
    final result = await protector.verifyProtection();

    // Assert
    expect(result, true);
    verify(mockLogger.info('Starting protection verification')).called(1);
    verify(mockLogger.info('Protection verification completed')).called(1);
  });

  test('generateReport() should include issues when initialized', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    await protector.initialize();

    // Act
    final report = await protector.generateReport();

    // Assert
    expect(report.isSecure, true);
    expect(report.issues.length, 1);
    expect(report.issues.first.severity, SecuritySeverity.low);
    expect(report.metadata.containsKey('lastCheck'), true);
    expect(report.metadata.containsKey('checkDuration'), true);
  });

  test('generateReport() should return error report when not initialized',
      () async {
    // Arrange
    when(mockLogger.error(any)).thenAnswer((_) => Future.value());

    // Act
    final report = await protector.generateReport();

    // Assert
    expect(report.isSecure, false);
    expect(report.issues.isEmpty, true);
    expect(report.metadata['error'], 'Protector not initialized');
  });

  test('dispose() should cleanup resources', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    await protector.initialize();

    // Act
    await protector.dispose();

    // Assert
    expect(protector.isInitialized, false);
    verify(mockLogger.info('StorageProtector disposed')).called(1);
  });
}
