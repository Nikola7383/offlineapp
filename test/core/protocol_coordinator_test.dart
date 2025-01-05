import 'package:test/test.dart';
import '../../lib/core/protocol_coordinator.dart';
import '../../lib/security/secure_cleanup.dart';

void main() {
  late ProtocolCoordinator coordinator;
  late MockAutonomousSecurityCore mockAI;
  late MockEmergencyRecoverySystem mockEmergency;

  setUp(() {
    mockAI = MockAutonomousSecurityCore();
    mockEmergency = MockEmergencyRecoverySystem();
    coordinator = ProtocolCoordinator(
      ai: mockAI,
      emergency: mockEmergency,
    );
  });

  tearDown(() {
    coordinator.dispose();
  });

  group('State Transitions', () {
    test('Should handle rapid state changes', () async {
      // Pokušaj brze promene stanja
      final futures = List.generate(
          10,
          (i) => coordinator.handleStateTransition(
                SystemState.heightenedSecurity,
                trigger: 'rapid_test_$i',
              ));

      final results = await Future.wait(futures);
      expect(results.where((r) => r).length, equals(1));
    });

    test('Should prevent invalid state transitions', () async {
      // Pokušaj prelaska iz normal u emergency bez međukoraka
      final result = await coordinator.handleStateTransition(
        SystemState.emergency,
        trigger: 'invalid_transition',
      );

      expect(result, isFalse);
    });

    test('Should handle concurrent transitions', () async {
      // Simuliraj konkurentne zahteve za promenu stanja
      final futures = await Future.wait([
        coordinator.handleStateTransition(
          SystemState.heightenedSecurity,
          trigger: 'concurrent_1',
        ),
        coordinator.handleStateTransition(
          SystemState.phoenix,
          trigger: 'concurrent_2',
        ),
        coordinator.handleStateTransition(
          SystemState.emergency,
          trigger: 'concurrent_3',
        ),
      ]);

      // Samo jedna tranzicija treba da uspe
      expect(futures.where((f) => f).length, equals(1));
    });
  });

  group('System Integrity', () {
    test('Should detect compromised state', () async {
      mockAI.simulateCompromised(true);

      final result = await coordinator.handleStateTransition(
        SystemState.heightenedSecurity,
        trigger: 'integrity_test',
      );

      expect(result, isFalse);
      verify(mockEmergency.initiateEmergencyRecovery).called(1);
    });

    test('Should handle cleanup failures', () async {
      // Simuliraj neuspešno čišćenje
      mockCleanupFailure();

      final result = await coordinator.handleStateTransition(
        SystemState.normal,
        trigger: 'cleanup_test',
      );

      expect(result, isFalse);
      verify(mockEmergency.initiateEmergencyRecovery).called(1);
    });
  });

  group('Error Recovery', () {
    test('Should recover from transition errors', () async {
      // Simuliraj grešku pa uspeh
      mockAI.simulateTransitionError(2); // Fail twice then succeed

      final result = await coordinator.handleStateTransition(
        SystemState.heightenedSecurity,
        trigger: 'error_recovery_test',
      );

      expect(result, isTrue);
    });

    test('Should handle timeout scenarios', () async {
      // Simuliraj timeout
      mockAI.simulateTimeout(true);

      final result = await coordinator.handleStateTransition(
        SystemState.heightenedSecurity,
        trigger: 'timeout_test',
      );

      expect(result, isFalse);
      verify(mockEmergency.initiateEmergencyRecovery).called(1);
    });
  });

  group('Memory Management', () {
    test('Should clean up resources after transitions', () async {
      await coordinator.handleStateTransition(
        SystemState.heightenedSecurity,
        trigger: 'memory_test',
      );

      // Proveri da li su resursi očišćeni
      expect(await getActiveResources(), isEmpty);
    });

    test('Should handle out of memory scenarios', () async {
      // Simuliraj out of memory
      mockOutOfMemory(true);

      final result = await coordinator.handleStateTransition(
        SystemState.heightenedSecurity,
        trigger: 'oom_test',
      );

      expect(result, isFalse);
      verify(mockEmergency.initiateEmergencyRecovery).called(1);
    });
  });
}
