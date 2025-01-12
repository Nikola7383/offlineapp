import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../../lib/security/emergency/emergency_mode_manager.dart';
import '../../lib/core/interfaces/emergency_mode_interface.dart';
import '../../lib/models/emergency_options.dart';
import '../mocks/security_mocks.mocks.dart';

void main() {
  late MockILoggerService mockLogger;
  late EmergencyModeManager manager;

  setUp(() {
    mockLogger = MockILoggerService();
    manager = EmergencyModeManager(mockLogger);
  });

  test('initialize() should set isInitialized to true', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    when(mockLogger.warning(any)).thenAnswer((_) => Future.value());

    // Act
    await manager.initialize();

    // Assert
    expect(manager.isInitialized, true);
    verify(mockLogger.info('Initializing EmergencyModeManager')).called(1);
    verify(mockLogger.info('EmergencyModeManager initialized')).called(1);
  });

  test('initialize() should not initialize twice', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    when(mockLogger.warning(any)).thenAnswer((_) => Future.value());

    // Act
    await manager.initialize();
    await manager.initialize();

    // Assert
    verify(mockLogger.warning('EmergencyModeManager already initialized'))
        .called(1);
  });

  test('activate() should fail if not initialized', () async {
    // Arrange
    when(mockLogger.error(any)).thenAnswer((_) => Future.value());
    final options = EmergencyOptions(
      limitedOperations: true,
      enhancedSecurity: true,
      preserveEssentialFunctions: true,
    );

    // Act
    await manager.activate(options: options);

    // Assert
    verify(mockLogger.error('EmergencyModeManager not initialized')).called(1);
  });

  test('activate() should emit activation event', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    await manager.initialize();
    final options = EmergencyOptions(
      limitedOperations: true,
      enhancedSecurity: true,
      preserveEssentialFunctions: true,
    );

    // Act & Assert
    expectLater(
      manager.modeEvents,
      emits(
        predicate<EmergencyModeEvent>((event) =>
            event.type == EmergencyEventType.activated &&
            event.data.containsKey('timestamp') &&
            event.data.containsKey('options')),
      ),
    );

    await manager.activate(options: options);
  });

  test('deactivate() should fail if not initialized', () async {
    // Arrange
    when(mockLogger.error(any)).thenAnswer((_) => Future.value());

    // Act
    await manager.deactivate();

    // Assert
    verify(mockLogger.error('EmergencyModeManager not initialized')).called(1);
  });

  test('deactivate() should emit deactivation event', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    await manager.initialize();
    final options = EmergencyOptions(
      limitedOperations: true,
      enhancedSecurity: true,
      preserveEssentialFunctions: true,
    );
    await manager.activate(options: options);

    // Act & Assert
    expectLater(
      manager.modeEvents,
      emits(
        predicate<EmergencyModeEvent>((event) =>
            event.type == EmergencyEventType.deactivated &&
            event.data.containsKey('timestamp')),
      ),
    );

    await manager.deactivate();
  });

  test('isActive() should return correct state', () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    await manager.initialize();
    final options = EmergencyOptions(
      limitedOperations: true,
      enhancedSecurity: true,
      preserveEssentialFunctions: true,
    );

    // Act & Assert
    expect(await manager.isActive(), false);
    await manager.activate(options: options);
    expect(await manager.isActive(), true);
    await manager.deactivate();
    expect(await manager.isActive(), false);
  });

  test('generateReport() should include current state when initialized',
      () async {
    // Arrange
    when(mockLogger.info(any)).thenAnswer((_) => Future.value());
    await manager.initialize();
    final options = EmergencyOptions(
      limitedOperations: true,
      enhancedSecurity: true,
      preserveEssentialFunctions: true,
    );
    await manager.activate(options: options);

    // Act
    final report = await manager.generateReport();

    // Assert
    expect(report.isActive, true);
    expect(report.currentOptions.limitedOperations, true);
    expect(report.currentOptions.enhancedSecurity, true);
    expect(report.currentOptions.preserveEssentialFunctions, true);
    expect(report.activeRestrictions.length, 3);
    expect(report.metadata.containsKey('lastCheck'), true);
    expect(report.metadata['status'], 'active');
  });

  test('generateReport() should return default report when not initialized',
      () async {
    // Arrange
    when(mockLogger.error(any)).thenAnswer((_) => Future.value());

    // Act
    final report = await manager.generateReport();

    // Assert
    expect(report.isActive, false);
    expect(report.activeRestrictions.isEmpty, true);
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
    verify(mockLogger.info('EmergencyModeManager disposed')).called(1);
  });
}
