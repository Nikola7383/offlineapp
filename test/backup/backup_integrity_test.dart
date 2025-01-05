import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/core/storage/storage_manager.dart';
import 'package:your_app/core/security/encryption_service.dart';

void main() {
  late StorageManager storage;
  late EncryptionService encryption;

  setUp(() {
    storage = StorageManager(logger: LoggerService());
    encryption = EncryptionService(logger: LoggerService());
  });

  group('Backup Integrity Tests', () {
    test('Should create verifiable backups', () async {
      // Kreira backup sa checksum-om
      final backup = await storage.createBackup(
        includeChecksum: true,
      );

      // Verifikuje backup
      final verified = await storage.verifyBackup(backup);

      expect(verified.isValid, isTrue);
      expect(verified.checksumMatch, isTrue);
      expect(verified.encryptionValid, isTrue);
    });

    test('Should detect corrupted backups', () async {
      final backup = await storage.createBackup();

      // Namerno korumpira backup
      await _corruptBackupFile(backup.path);

      // Pokušaj verifikacije
      final verification = await storage.verifyBackup(backup);

      expect(verification.isValid, isFalse);
      expect(verification.corruptionDetected, isTrue);
    });

    test('Should successfully restore from backup', () async {
      // Kreira i verifikuje backup
      final backup = await storage.createBackup();

      // Simulira gubitak podataka
      await storage.clearAllData();

      // Vraća iz backup-a
      final restored = await storage.restoreFromBackup(backup);

      expect(restored.success, isTrue);
      expect(restored.dataIntegrityMaintained, isTrue);
      expect(restored.messagesRestored, greaterThan(0));
    });
  });
}
