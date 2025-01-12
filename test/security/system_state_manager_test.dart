import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../../lib/security/state/system_state_manager.dart';
import '../../lib/core/interfaces/system_state_interface.dart';
import '../mocks/security_mocks.mocks.dart';

void main() {
  late MockILoggerService mockLogger;
  late SystemStateManager manager;

  setUp(() {
    mockLogger = MockILoggerService();
    manager = SystemStateManager(mockLogger);
  });

  test('initialize() should set isInitialized to true', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    when(mockLogger.warning(any)).thenAnswer((_) => Future.value());

    // Act
    await manager.initialize();

    // Assert
    expect(manager.isInitialized, true);
    verify(mockLogger.info('Initializing SystemStateManager')).called(1);
    verify(mockLogger.info('SystemStateManager initialized')).called(1);
  });

  test('initialize() should not initialize twice', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    when(mockLogger.warning(any)).thenAnswer((_) => Future.value());

    // Act
    await manager.initialize();
    await manager.initialize();

    // Assert
    verify(mockLogger.warning('SystemStateManager already initialized'))
        .called(1);
  });

  test('getCurrentState() should return default state when not initialized',
      () async {
    // Arrange
    when(mockLogger.error(any)).thenAnswer((_) => Future.value());

    // Act
    final state = await manager.getCurrentState();

    // Assert
    expect(state.isOperational, false);
    expect(state.mode, SystemMode.normal);
    expect(state.configuration.isEmpty, true);
    expect(state.activeProcesses.isEmpty, true);
    verify(mockLogger.error('SystemStateManager not initialized')).called(1);
  });

  test('getCurrentState() should return valid state when initialized',
      () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    await manager.initialize();

    // Act
    final state = await manager.getCurrentState();

    // Assert
    expect(state.isOperational, true);
    expect(state.mode, SystemMode.normal);
    expect(state.configuration.containsKey('securityLevel'), true);
    expect(state.activeProcesses.isNotEmpty, true);
  });

  test('updateState() should emit state change event', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    await manager.initialize();
    final newState = SystemState(
      isOperational: true,
      mode: SystemMode.emergency,
      configuration: {'securityLevel': 'high'},
      activeProcesses: ['security_monitor'],
    );

    // Act & Assert
    expectLater(
      manager.stateChanges,
      emits(
        predicate<SystemStateChange>((change) =>
            change.previousMode == SystemMode.normal &&
            change.newMode == SystemMode.emergency &&
            change.reason == 'Manual state update'),
      ),
    );

    await manager.updateState(newState);
  });

  test('updateState() should fail if not initialized', () async {
    // Arrange
    when(mockLogger.error(any)).thenAnswer((_) => Future.value());
    final newState = SystemState(
      isOperational: true,
      mode: SystemMode.emergency,
      configuration: {'securityLevel': 'high'},
      activeProcesses: ['security_monitor'],
    );

    // Act
    await manager.updateState(newState);

    // Assert
    verify(mockLogger.error('SystemStateManager not initialized')).called(1);
  });

  test('generateReport() should include issues when initialized', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    await manager.initialize();

    // Act
    final report = await manager.generateReport();

    // Assert
    expect(report.isHealthy, true);
    expect(report.issues.length, 1);
    expect(report.issues.first.severity, StateSeverity.low);
    expect(report.metadata.containsKey('lastCheck'), true);
    expect(report.metadata.containsKey('currentMode'), true);
  });

  test('generateReport() should return error report when not initialized',
      () async {
    // Arrange
    when(mockLogger.error(any)).thenAnswer((_) => Future.value());

    // Act
    final report = await manager.generateReport();

    // Assert
    expect(report.isHealthy, false);
    expect(report.issues.isEmpty, true);
    expect(report.metadata['error'], 'Manager not initialized');
  });

  test('dispose() should cleanup resources', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    await manager.initialize();

    // Act
    await manager.dispose();

    // Assert
    expect(manager.isInitialized, false);
    verify(mockLogger.info('SystemStateManager disposed')).called(1);
  });
}
