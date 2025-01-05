import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/core/database/database_service.dart';
import 'package:your_app/core/security/encryption_service.dart';

void main() {
  late DatabaseService db;
  late EncryptionService encryption;

  setUp(() {
    db = DatabaseService(logger: LoggerService());
    encryption = EncryptionService(logger: LoggerService());
  });

  group('Data Integrity Tests', () {
    test('Should maintain message integrity during sync', () async {
      // Kreira test poruke sa poznatim hash-evima
      final messages = await _createTestMessagesWithHashes();

      // Simulira sync između peer-ova
      await _simulateMessageSync(messages);

      // Verifikuje integritet
      final synced = await db.getAllMessages();
      for (final msg in synced) {
        final hash = await encryption.calculateHash(msg);
        expect(hash, equals(msg.originalHash));
      }
    });

    test('Should detect and repair database corruption', () async {
      // Namerno korumpira neke zapise
      await _simulateDatabaseCorruption();

      // Pokreće proveru integriteta
      final integrityCheck = await db.verifyIntegrity();

      expect(integrityCheck.corruptedRecords, isGreaterThan(0));
      expect(integrityCheck.repairedRecords,
          equals(integrityCheck.corruptedRecords));
      expect(integrityCheck.dataLoss, isFalse);
    });

    test('Should maintain referential integrity', () async {
      // Testira veze između poruka i njihovih attachmenta
      final integrity = await _checkReferentialIntegrity();

      expect(integrity.orphanedAttachments, equals(0));
      expect(integrity.brokenReferences, equals(0));
      expect(integrity.consistencyVerified, isTrue);
    });
  });
}
