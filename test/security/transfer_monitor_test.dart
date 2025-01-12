import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../../lib/security/monitoring/transfer_monitor.dart';
import '../../lib/core/interfaces/transfer_monitor_interface.dart';
import '../mocks/security_mocks.mocks.dart';

void main() {
  late MockILoggerService mockLogger;
  late TransferMonitor monitor;

  setUp(() {
    mockLogger = MockILoggerService();
    monitor = TransferMonitor(mockLogger);
  });

  test('initialize() should set isInitialized to true', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    when(mockLogger.warning(any)).thenAnswer((_) => Future.value());

    // Act
    await monitor.initialize();

    // Assert
    expect(monitor.isInitialized, true);
    verify(mockLogger.info('Initializing TransferMonitor')).called(1);
    verify(mockLogger.info('TransferMonitor initialized')).called(1);
  });

  test('initialize() should not initialize twice', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    when(mockLogger.warning(any)).thenAnswer((_) => Future.value());

    // Act
    await monitor.initialize();
    await monitor.initialize();

    // Assert
    verify(mockLogger.warning('TransferMonitor already initialized')).called(1);
  });

  test('recordAttempt() should fail if not initialized', () async {
    // Arrange
    when(mockLogger.error(any)).thenAnswer((_) => Future.value());

    // Act
    await monitor.recordAttempt(1);

    // Assert
    verify(mockLogger.error('TransferMonitor not initialized')).called(1);
  });

  test('recordAttempt() should record attempt and emit event', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    await monitor.initialize();

    // Act & Assert
    expectLater(
      monitor.transferEvents,
      emits(
        predicate<TransferEvent>((event) =>
            event.type == TransferEventType.attemptStarted &&
            event.data['attempt'] == 1),
      ),
    );

    await monitor.recordAttempt(1);
  });

  test('recordFailure() should record failure and emit event', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    when(mockLogger.warning(any)).thenAnswer((_) => Future.value());
    await monitor.initialize();
    final error = Exception('Test error');

    // Act & Assert
    expectLater(
      monitor.transferEvents,
      emits(
        predicate<TransferEvent>((event) =>
            event.type == TransferEventType.attemptFailed &&
            event.data['attempt'] == 1 &&
            event.data['error'] == error.toString()),
      ),
    );

    await monitor.recordFailure(1, error);
  });

  test('shouldSwitchToQr() should return true after 3 failures', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    when(mockLogger.warning(any)).thenAnswer((_) => Future.value());
    await monitor.initialize();
    final error = Exception('Test error');

    // Act
    await monitor.recordFailure(1, error);
    await monitor.recordFailure(2, error);
    await monitor.recordFailure(3, error);
    final shouldSwitch = await monitor.shouldSwitchToQr();

    // Assert
    expect(shouldSwitch, true);
  });

  test('getStats() should return current transfer statistics', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    when(mockLogger.warning(any)).thenAnswer((_) => Future.value());
    await monitor.initialize();
    final error = Exception('Test error');

    // Act
    await monitor.recordAttempt(1);
    await monitor.recordFailure(1, error);
    await monitor.recordAttempt(2);
    final stats = await monitor.getStats();

    // Assert
    expect(stats.totalAttempts, 2);
    expect(stats.failedAttempts, 1);
    expect(stats.isStable, true);
  });

  test('dispose() should cleanup resources', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    await monitor.initialize();

    // Act
    await monitor.dispose();

    // Assert
    expect(monitor.isInitialized, false);
    verify(mockLogger.info('TransferMonitor disposed')).called(1);
  });
}
