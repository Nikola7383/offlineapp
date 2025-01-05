import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/services/encryption_service.dart';
import 'package:your_app/services/api_service.dart';

void main() {
  group('Security Tests', () {
    test('Data encryption test', () {
      final encryption = EncryptionService();
      final plainText = 'Sensitive data';

      final encrypted = encryption.encrypt(plainText);
      final decrypted = encryption.decrypt(encrypted);

      expect(encrypted, isNot(equals(plainText)));
      expect(decrypted, equals(plainText));
    });

    test('Token security test', () async {
      final api = ApiService();
      final token = await api.login('test', 'password');

      expect(token.length > 32, true); // Minimum token length
      expect(token.contains('.'), true); // JWT format
    });

    test('SQL injection prevention', () async {
      final db = DatabaseService();
      final maliciousInput = "'; DROP TABLE messages; --";

      // Should handle malicious input safely
      await expectLater(
        () => db.saveMessage(Message(
          id: '1',
          content: maliciousInput,
          sender: 'Test',
          timestamp: DateTime.now(),
        )),
        returnsNormally,
      );
    });
  });
}
