import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/core/admin/master_admin.dart';
import 'package:secure_event_app/core/admin/secret_master.dart';
import 'package:secure_event_app/core/security/encryption.dart';
import 'package:secure_event_app/core/security/key_manager.dart';

void main() {
  late KeyManager keyManager;
  late MasterAdmin masterAdmin;
  late SecretMaster secretMaster;

  setUp(() async {
    keyManager = KeyManager();
    await keyManager.initialize();
    
    masterAdmin = MasterAdmin(keyManager: keyManager);
    secretMaster = SecretMaster(keyManager: keyManager);
  });

  tearDown(() async {
    await keyManager.dispose();
  });

  group('Admin System Tests', () {
    test('MasterAdmin should verify admin credentials', () async {
      final result = await masterAdmin.verifyCredentials(
        username: 'admin',
        password: 'masterpass123'
      );
      expect(result, isTrue);
    });

    test('SecretMaster should handle encrypted data', () async {
      final data = 'test_secret';
      final encrypted = await secretMaster.encryptData(data);
      final decrypted = await secretMaster.decryptData(encrypted);
      expect(decrypted, equals(data));
    });
  });
} 