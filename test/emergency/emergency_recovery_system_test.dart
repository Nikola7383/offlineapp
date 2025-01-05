import 'package:test/test.dart';
import '../../lib/emergency/emergency_recovery_system.dart';
import '../../lib/ai/autonomous_security_core.dart';
import '../../lib/mesh/secure_mesh_network.dart';

void main() {
  late EmergencyRecoverySystem recovery;
  late MockAutonomousSecurityCore mockAI;
  late MockSecureMeshNetwork mockNetwork;

  setUp(() {
    mockAI = MockAutonomousSecurityCore();
    mockNetwork = MockSecureMeshNetwork();
    recovery = EmergencyRecoverySystem(
      ai: mockAI,
      network: mockNetwork,
    );
  });

  tearDown(() {
    recovery.dispose();
  });

  group('Emergency Activation', () {
    test('Should activate emergency protocol', () async {
      await recovery.initiateEmergencyRecovery(
        trigger: EmergencyTrigger.networkCompromised,
        context: {'reason': 'Critical breach detected'},
      );

      expect(mockNetwork.operationsPaused, isTrue);
    });

    test('Should prevent multiple emergency activations', () async {
      await recovery.initiateEmergencyRecovery(
        trigger: EmergencyTrigger.masterUnavailable,
        context: {'lastSeen': DateTime.now().toString()},
      );

      // Pokušaj druge aktivacije
      await expectLater(
        () => recovery.initiateEmergencyRecovery(
          trigger: EmergencyTrigger.adminsCompromised,
          context: {},
        ),
        returnsNormally,
      );
    });
  });

  group('Messenger Management', () {
    test('Should activate initial messengers', () async {
      await recovery.initiateEmergencyRecovery(
        trigger: EmergencyTrigger.networkCompromised,
        context: {},
      );

      // Sačekaj rotacioni interval
      await Future.delayed(Duration(milliseconds: 100));

      final messengers = await mockNetwork.getActiveMessengers();
      expect(messengers.length,
          lessThanOrEqualTo(EmergencyRecoverySystem.MAX_ACTIVE_MESSENGERS));
    });

    test('Should rotate messengers', () async {
      await recovery.initiateEmergencyRecovery(
        trigger: EmergencyTrigger.networkCompromised,
        context: {},
      );

      final initialMessengers = await mockNetwork.getActiveMessengers();

      // Sačekaj rotaciju
      await Future.delayed(EmergencyRecoverySystem.ROTATION_INTERVAL);

      final rotatedMessengers = await mockNetwork.getActiveMessengers();
      expect(rotatedMessengers, isNot(equals(initialMessengers)));
    });

    test('Should respect messenger lifetime', () async {
      await recovery.initiateEmergencyRecovery(
        trigger: EmergencyTrigger.networkCompromised,
        context: {},
      );

      // Sačekaj istek vremena glasnika
      await Future.delayed(EmergencyRecoverySystem.MESSENGER_LIFETIME);

      final expiredMessenger = (await mockNetwork.getActiveMessengers()).first;
      expect(expiredMessenger.isExpired, isTrue);
    });
  });

  group('Recovery Process', () {
    test('Should recover critical data', () async {
      await recovery.initiateEmergencyRecovery(
        trigger: EmergencyTrigger.criticalDataBreach,
        context: {
          'compromisedData': ['security_keys', 'user_roles']
        },
      );

      expect(mockNetwork.criticalDataRecovered, isTrue);
    });

    test('Should regenerate security protocols', () async {
      await recovery.initiateEmergencyRecovery(
        trigger: EmergencyTrigger.phoenixFailed,
        context: {},
      );

      expect(mockNetwork.securityProtocolsRegenerated, isTrue);
    });

    test('Should verify recovery success', () async {
      await recovery.initiateEmergencyRecovery(
        trigger: EmergencyTrigger.networkCompromised,
        context: {},
      );

      expect(mockNetwork.recoveryVerified, isTrue);
    });
  });

  group('Emergency Deactivation', () {
    test('Should properly deactivate emergency mode', () async {
      await recovery.initiateEmergencyRecovery(
        trigger: EmergencyTrigger.networkCompromised,
        context: {},
      );

      // Sačekaj završetak recovery procesa
      await Future.delayed(Duration(seconds: 1));

      expect(mockNetwork.operationsPaused, isFalse);
      expect(mockNetwork.getActiveMessengers(), isEmpty);
    });
  });
}

class MockAutonomousSecurityCore extends AutonomousSecurityCore {
  // Mock implementacija
}

class MockSecureMeshNetwork extends SecureMeshNetwork {
  bool operationsPaused = false;
  bool criticalDataRecovered = false;
  bool securityProtocolsRegenerated = false;
  bool recoveryVerified = false;
  final List<_EmergencyMessenger> _activeMessengers = [];

  Future<List<_EmergencyMessenger>> getActiveMessengers() async {
    return _activeMessengers;
  }
}
