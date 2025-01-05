import 'package:test/test.dart';
import '../../../lib/admin/verification/admin_verification_system.dart';

void main() {
  late AdminVerificationSystem verifier;

  setUp(() {
    verifier = AdminVerificationSystem();
  });

  group('Sound Verification', () {
    test('Should verify admin using sound', () async {
      final candidate = AdminCandidate(id: 'test_admin');

      // Simuliraj uspešnu zvučnu verifikaciju
      final success = await verifier.verifyNewAdmin(
        candidate: candidate,
        primaryMethod: VerificationType.sound,
        backupMethod: VerificationType.adminBuild,
      );

      expect(success, isTrue);
    });

    test('Should handle noisy environment', () async {
      // Simuliraj bučno okruženje
      await _simulateNoisyEnvironment();

      final success = await verifier.verifyNewAdmin(
        candidate: AdminCandidate(id: 'noise_test'),
        primaryMethod: VerificationType.sound,
        backupMethod: VerificationType.adminBuild,
      );

      expect(success, isTrue);
    });
  });

  group('Admin Build Verification', () {
    test('Should verify admin using build', () async {
      final build = await verifier.generateAdminBuild(
        candidate: AdminCandidate(id: 'build_test'),
      );

      expect(build.isValid, isTrue);
      expect(build.expiresAt, isNotNull);
    });

    test('Should expire after validity period', () async {
      final build = await verifier.generateAdminBuild(
        candidate: AdminCandidate(id: 'expiry_test'),
      );

      // Simuliraj prolazak vremena
      await _fastForward(Duration(hours: 25));

      expect(build.isValid, isFalse);
    });
  });

  group('Fallback Verification', () {
    test('Should fallback to backup method', () async {
      // Simuliraj neuspeh zvučne verifikacije
      await _simulateVerificationFailure(VerificationType.sound);

      final success = await verifier.verifyNewAdmin(
        candidate: AdminCandidate(id: 'fallback_test'),
        primaryMethod: VerificationType.sound,
        backupMethod: VerificationType.adminBuild,
      );

      expect(success, isTrue);
    });
  });
}
