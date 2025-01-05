import 'package:test/test.dart';
import '../../lib/monitoring/system_health_monitor.dart';
import '../../lib/core/protocol_coordinator.dart';

void main() {
  late SystemHealthMonitor monitor;
  late MockProtocolCoordinator mockCoordinator;

  setUp(() async {
    mockCoordinator = MockProtocolCoordinator();
    monitor = SystemHealthMonitor(coordinator: mockCoordinator);
    await monitor.initialize();
  });

  tearDown(() {
    monitor.dispose();
  });

  group('Initialization', () {
    test('Should initialize in isolated environment', () {
      expect(monitor, isNotNull);
    });

    test('Should prevent multiple initializations', () async {
      await monitor.initialize(); // Drugi pokušaj
      // Ne bi trebalo da baci grešku
    });
  });

  group('Health Monitoring', () {
    test('Should detect resource anomalies', () async {
      // Simuliraj visoku potrošnju resursa
      await _simulateHighResourceUsage();

      // Sačekaj da monitor reaguje
      await Future.delayed(SystemHealthMonitor.CHECK_INTERVAL);

      verify(mockCoordinator.handleStateTransition(
        SystemState.heightenedSecurity,
        trigger: 'health_monitor',
      )).called(1);
    });

    test('Should detect behavioral anomalies', () async {
      // Simuliraj sumnjivo ponašanje
      await _simulateAbnormalBehavior();

      await Future.delayed(SystemHealthMonitor.CHECK_INTERVAL);

      verify(mockCoordinator.handleStateTransition(
        any,
        trigger: 'health_monitor',
      )).called(1);
    });
  });

  group('Threat Response', () {
    test('Should handle high threats appropriately', () async {
      // Simuliraj ozbiljnu pretnju
      await _simulateHighThreat();

      await Future.delayed(SystemHealthMonitor.CHECK_INTERVAL);

      verify(mockCoordinator.handleStateTransition(
        SystemState.emergency,
        trigger: 'health_monitor',
      )).called(1);
    });

    test('Should handle low threats preventively', () async {
      // Simuliraj manju pretnju
      await _simulateLowThreat();

      await Future.delayed(SystemHealthMonitor.CHECK_INTERVAL);

      verify(mockCoordinator.handleStateTransition(
        SystemState.heightenedSecurity,
        trigger: 'health_monitor',
      )).called(1);
    });
  });

  group('Resource Management', () {
    test('Should maintain history limit', () async {
      // Generiši mnogo health update-ova
      for (var i = 0; i < SystemHealthMonitor.HISTORY_LIMIT + 100; i++) {
        await _generateHealthUpdate();
      }

      final historySize = await _getHistorySize();
      expect(historySize, lessThanOrEqualTo(SystemHealthMonitor.HISTORY_LIMIT));
    });

    test('Should clean up old data', () async {
      // Dodaj stare podatke
      await _addOldHealthData();

      // Sačekaj cleanup
      await Future.delayed(const Duration(seconds: 1));

      final oldDataCount = await _getOldDataCount();
      expect(oldDataCount, equals(0));
    });
  });

  group('Offline Operation', () {
    test('Should work without network', () async {
      // Simuliraj offline stanje
      await _simulateOffline();

      // Monitor bi trebalo da nastavi rad
      expect(monitor, isNotNull);
    });

    test('Should store data locally', () async {
      await _generateHealthUpdate();

      final isStoredLocally = await _isDataStoredLocally();
      expect(isStoredLocally, isTrue);
    });
  });
}

class MockProtocolCoordinator extends Mock implements ProtocolCoordinator {}
