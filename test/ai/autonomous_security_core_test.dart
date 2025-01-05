import 'package:test/test.dart';
import '../../lib/ai/autonomous_security_core.dart';
import '../../lib/security/security_types.dart';

void main() {
  late AutonomousSecurityCore ai;

  setUp(() async {
    ai = AutonomousSecurityCore();
    await ai.initialize();
  });

  tearDown(() {
    ai.dispose();
  });

  group('Initialization', () {
    test('Should initialize securely', () {
      expect(ai, isNotNull);
    });

    test('Should detect compromised models', () async {
      // Pokušaj kompromitovanja modela
      // TODO: Implementirati test
    });
  });

  group('Decision Making', () {
    test('Should make secure decisions', () async {
      final state = SecureNetworkState(
        nodes: 5,
        activeConnections: 3,
        messageCount: 100,
        lastIncident: null,
      );

      final decision = await ai.analyzeAndAct(state);
      expect(decision, isNotNull);
      expect(decision.confidence, greaterThan(0.5));
    });

    test('Should handle emergency situations', () async {
      // Simuliraj kritičnu situaciju
      final state = SecureNetworkState(
        nodes: 1, // Kritično malo čvorova
        activeConnections: 0,
        messageCount: 999999, // Sumnjivo mnogo poruka
        lastIncident: DateTime.now(),
      );

      final decision = await ai.analyzeAndAct(state);
      expect(decision.action, equals(SecurityAction.initiatePhoenix));
    });
  });

  group('Model Protection', () {
    test('Should prevent unauthorized modifications', () {
      // TODO: Implementirati test
    });
  });
}
