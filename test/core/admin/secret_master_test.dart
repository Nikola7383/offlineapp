import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/core/admin/secret_master.dart';
import 'package:secure_event_app/core/security/key_manager.dart';

void main() {
  late KeyManager keyManager;
  late SecretMaster secretMaster;

  setUp(() async {
    keyManager = KeyManager();
    await keyManager.initialize();
    secretMaster = SecretMaster(keyManager: keyManager);
  });

  group('SecretMaster Tests', () {
    test('should encrypt and decrypt data correctly', () async {
      final originalData = 'test_secret_data';

      final encrypted = await secretMaster.encryptData(originalData);
      expect(encrypted, isNot(equals(originalData)));

      final decrypted = await secretMaster.decryptData(encrypted);
      expect(decrypted, equals(originalData));
    });
  });
}
