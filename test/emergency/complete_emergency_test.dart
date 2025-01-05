import 'package:test/test.dart';
import '../../lib/emergency/complete_emergency_system.dart';

void main() {
  late CompleteEmergencySystem emergencySystem;

  setUp(() async {
    emergencySystem = CompleteEmergencySystem();
    await emergencySystem.initializeEmergencySystems();
  });

  group('Emergency Protocols', () {
    test('Should handle security breach', () async {
      await emergencySystem.executeEmergencyProtocol(
        type: EmergencyType.securityBreach,
        level: SecurityLevel.critical,
      );

      // Verifikuj da su svi protokoli izvršeni
      expect(await _verifyProtocolExecution(), isTrue);
    });

    test('Should perform complete shutdown', () async {
      final result = await emergencySystem.executeEmergencyProtocol(
        type: EmergencyType.systemFailure,
        level: SecurityLevel.critical,
      );

      expect(result.isShutdownComplete, isTrue);
      expect(result.dataSecured, isTrue);
    });
  });

  group('Deployment System', () {
    test('Should deploy successfully', () async {
      final config = DeploymentConfig(
        admins: _generateTestAdmins(5),
        settings: TestSettings(),
      );

      final result = await emergencySystem.deploySystem(
        config: config,
        admins: config.admins,
      );

      expect(result.isDeployed, isTrue);
      expect(result.adminsReady, isTrue);
    });
  });

  group('Post-Event Cleanup', () {
    test('Should cleanup all temporary data', () async {
      final eventData = await _generateTestEventData();
      final config = CleanupConfig();

      await emergencySystem.executeCleanup(
        eventData: eventData,
        config: config,
      );

      expect(await _verifyCleanup(), isTrue);
    });

    test('Should generate complete reports', () async {
      final eventData = await _generateTestEventData();
      final config = CleanupConfig(
        generateReports: true,
      );

      final result = await emergencySystem.executeCleanup(
        eventData: eventData,
        config: config,
      );

      expect(result.reports, isNotEmpty);
      expect(result.reports.first.isComplete, isTrue);
    });
  });

  group('Documentation & Training', () {
    test('Should prepare all materials', () async {
      await emergencySystem.prepareTrainingMaterials();

      final materials = await _getTrainingMaterials();
      expect(materials.documentation, isNotEmpty);
      expect(materials.scenarios, isNotEmpty);
      expect(materials.emergencyGuides, isNotEmpty);
    });

    test('Should train admins successfully', () async {
      final admins = _generateTestAdmins(5);

      await emergencySystem.deploySystem(
        config: DeploymentConfig(),
        admins: admins,
      );

      for (final admin in admins) {
        expect(admin.isFullyTrained, isTrue);
      }
    });
  });
}
