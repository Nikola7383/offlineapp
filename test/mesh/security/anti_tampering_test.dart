import 'package:test/test.dart';
import '../../../lib/mesh/security/anti_tampering.dart';
import '../../../lib/mesh/security/security_types.dart';

void main() {
  late AntiTampering antiTampering;

  setUp(() {
    antiTampering = AntiTampering();
  });

  tearDown(() {
    antiTampering.dispose();
  });

  group('Module Registration', () {
    test('Should register new module successfully', () {
      final moduleId = 'test_module';
      final initialState = [1, 2, 3, 4, 5];

      antiTampering.registerModule(moduleId, initialState);

      expect(
        antiTampering.verifyIntegrity(moduleId, initialState),
        isTrue,
      );
    });

    test('Should fail verification for unregistered module', () {
      final moduleId = 'unknown_module';
      final state = [1, 2, 3];

      expect(
        antiTampering.verifyIntegrity(moduleId, state),
        isFalse,
      );
    });
  });

  group('Integrity Verification', () {
    test('Should detect state changes', () {
      final moduleId = 'test_module';
      final initialState = [1, 2, 3, 4, 5];
      final modifiedState = [1, 2, 3, 4, 6];

      antiTampering.registerModule(moduleId, initialState);

      expect(
        antiTampering.verifyIntegrity(moduleId, modifiedState),
        isFalse,
      );
    });

    test('Should handle state updates', () {
      final moduleId = 'test_module';
      final initialState = [1, 2, 3];
      final newState = [4, 5, 6];

      antiTampering.registerModule(moduleId, initialState);
      antiTampering.updateModuleState(moduleId, newState);

      expect(
        antiTampering.verifyIntegrity(moduleId, newState),
        isTrue,
      );
    });

    test('Should emit event after multiple failures', () async {
      final moduleId = 'test_module';
      final initialState = [1, 2, 3];
      final badState = [7, 8, 9];

      antiTampering.registerModule(moduleId, initialState);

      expect(
        antiTampering.securityEvents,
        emits(SecurityEvent.attackDetected),
      );

      // Simuliraj više neuspelih provera
      for (var i = 0; i < 4; i++) {
        antiTampering.verifyIntegrity(moduleId, badState);
      }
    });
  });

  group('Compromise Handling', () {
    test('Should reject all operations after compromise', () async {
      final moduleId = 'test_module';
      final initialState = [1, 2, 3];
      final badState = [7, 8, 9];

      antiTampering.registerModule(moduleId, initialState);

      // Izazovi kompromitovanje
      for (var i = 0; i < 4; i++) {
        antiTampering.verifyIntegrity(moduleId, badState);
      }

      // Sačekaj da se obradi događaj
      await Future.delayed(Duration(milliseconds: 100));

      // Proveri da li su nove operacije odbijene
      expect(
        antiTampering.verifyIntegrity(moduleId, initialState),
        isFalse,
      );
    });
  });
}
