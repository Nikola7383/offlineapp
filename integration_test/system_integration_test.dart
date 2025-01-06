import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End System Tests', () {
    late EmergencyService emergencyService;
    late MeshNetwork meshNetwork;
    late SoundProtocol soundProtocol;
    late SecurityService securityService;

    setUp(() async {
      // Inicijalizacija realnih servisa (ne mockova)
      securityService = await SecurityService.initialize();
      meshNetwork = await MeshNetwork.initialize();
      soundProtocol = await SoundProtocol.initialize();

      emergencyService = EmergencyService(
        storage: SecureStorage(),
        mesh: meshNetwork,
        sound: soundProtocol,
        security: securityService,
        logger: LoggerService(),
      );
    });

    testWidgets('Complete Emergency Scenario', (tester) async {
      // 1. Setup sistema
      await tester.pumpAndSettle();

      // 2. Simulacija network failure
      await meshNetwork.simulateFailure();

      // 3. Aktivacija emergency protokola
      await emergencyService.activateEmergencyProtocol(
        activatorId: 'secret_master_1',
        type: EmergencyType.networkFailure,
      );

      // 4. Verifikacija da je sound protocol aktiviran
      expect(soundProtocol.isActive, true);

      // 5. Verifikacija recovery-ja
      await tester.pumpAndSettle(Duration(seconds: 5));
      expect(meshNetwork.isOperational, true);
    });

    testWidgets('Full Security Protocol Test', (tester) async {
      // 1. Kreiranje test poruke
      final message = Message(
        id: 'test_1',
        content: 'Kritična poruka',
        priority: Priority.critical,
      );

      // 2. Simulacija system compromise
      await securityService.simulateCompromise();

      // 3. Verifikacija automatic detection
      await tester.pumpAndSettle();
      expect(securityService.compromiseDetected, true);

      // 4. Verifikacija automatic response
      expect(emergencyService.isActive, true);
      expect(meshNetwork.isIsolated, true);
    });
  });
}
