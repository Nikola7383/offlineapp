import 'dart:typed_data';
import 'package:test/test.dart';
import '../../../lib/mesh/security/security_manager.dart';
import '../../../lib/mesh/security/security_types.dart';

void main() {
  late SecurityManager security;

  setUp(() {
    security = SecurityManager();
  });

  tearDown(() {
    security.dispose();
  });

  group('Basic Encryption', () {
    test('Should encrypt and decrypt data successfully', () async {
      final originalData = 'Test message'.codeUnits;

      final encrypted = await security.encrypt(originalData);
      expect(encrypted, isNotNull);
      expect(encrypted.data.length, greaterThan(originalData.length));

      final decrypted = await security.decrypt(encrypted);
      expect(decrypted, equals(Uint8List.fromList(originalData)));
    });

    test('Should generate different ciphertexts for same data', () async {
      final data = 'Test message'.codeUnits;

      final encrypted1 = await security.encrypt(data);
      final encrypted2 = await security.encrypt(data);

      expect(encrypted1.data, isNot(equals(encrypted2.data)));
    });

    test('Should fail with invalid key', () async {
      final data = 'Test message'.codeUnits;
      final encrypted = await security.encrypt(data);

      // Modifikuj keyId da simuliraš pogrešan ključ
      final invalidMessage = EncryptedMessage(
        data: encrypted.data,
        keyId: 'invalid_key',
        level: encrypted.level,
        signature: encrypted.signature,
      );

      expect(() => security.decrypt(invalidMessage), throwsException);
    });
  });

  group('Advanced Encryption', () {
    test('Should use post-quantum encryption', () async {
      final data = 'Sensitive data'.codeUnits;

      final encrypted = await security.encrypt(
        data,
        level: EncryptionLevel.advanced,
      );

      expect(encrypted.level, equals(EncryptionLevel.advanced));

      final decrypted = await security.decrypt(encrypted);
      expect(decrypted, equals(Uint8List.fromList(data)));
    });

    test('Should produce longer ciphertext for advanced encryption', () async {
      final data = 'Test message'.codeUnits;

      final basicEncrypted = await security.encrypt(
        data,
        level: EncryptionLevel.basic,
      );

      final advancedEncrypted = await security.encrypt(
        data,
        level: EncryptionLevel.advanced,
      );

      expect(
        advancedEncrypted.data.length,
        greaterThan(basicEncrypted.data.length),
      );
    });
  });

  group('Phoenix Protocol', () {
    test('Should activate phoenix mode on multiple anomalies', () async {
      // Simuliraj nekoliko napada
      for (var i = 0; i < 5; i++) {
        try {
          await security.decrypt(EncryptedMessage(
            data: Uint8List(10),
            keyId: 'invalid',
            level: EncryptionLevel.basic,
            signature: List.filled(32, 0),
          ));
        } catch (_) {}
      }

      // Sledeća enkripcija treba da koristi Phoenix nivo
      final encrypted = await security.encrypt('test'.codeUnits);
      expect(encrypted.level, equals(EncryptionLevel.phoenix));
    });

    test('Should change encryption pattern over time', () async {
      final data = 'Test message'.codeUnits;

      // Sačekaj da se promeni Phoenix iteracija
      await Future.delayed(Duration(seconds: 1));

      final encrypted1 = await security.encrypt(
        data,
        level: EncryptionLevel.phoenix,
      );

      // Sačekaj novu iteraciju
      await Future.delayed(Duration(seconds: 5));

      final encrypted2 = await security.encrypt(
        data,
        level: EncryptionLevel.phoenix,
      );

      expect(encrypted1.metadata['iteration'],
          isNot(equals(encrypted2.metadata['iteration'])));
    });
  });

  group('Security Events', () {
    test('Should emit events on security anomalies', () async {
      expect(
        security.securityEvents,
        emits(SecurityEvent.attackDetected),
      );

      // Pokušaj dekriptovanja sa nevalidnim potpisom
      try {
        await security.decrypt(EncryptedMessage(
          data: Uint8List(10),
          keyId: 'invalid',
          level: EncryptionLevel.basic,
          signature: List.filled(32, 0),
        ));
      } catch (_) {}
    });

    test('Should track multiple security events', () async {
      final events = <SecurityEvent>[];
      final subscription = security.securityEvents.listen(events.add);

      // Simuliraj nekoliko napada
      for (var i = 0; i < 3; i++) {
        try {
          await security.decrypt(EncryptedMessage(
            data: Uint8List(10),
            keyId: 'invalid',
            level: EncryptionLevel.basic,
            signature: List.filled(32, 0),
          ));
        } catch (_) {}
      }

      await Future.delayed(Duration(milliseconds: 100));
      expect(events.length, greaterThanOrEqualTo(3));

      await subscription.cancel();
    });
  });

  group('Key Management', () {
    test('Should rotate keys periodically', () async {
      final data = 'Test message'.codeUnits;

      final encrypted = await security.encrypt(data);
      final initialKeyId = encrypted.keyId;

      // Sačekaj rotaciju ključeva
      await Future.delayed(Duration(seconds: 2));

      final newEncrypted = await security.encrypt(data);
      expect(newEncrypted.keyId, isNot(equals(initialKeyId)));
    });

    test('Should handle expired keys gracefully', () async {
      final data = 'Test message'.codeUnits;
      final encrypted = await security.encrypt(data);

      // Sačekaj da ključ istekne
      await Future.delayed(Duration(seconds: 2));

      // Trebalo bi još uvek da možemo da dekriptujemo sa starim ključem
      final decrypted = await security.decrypt(encrypted);
      expect(decrypted, equals(Uint8List.fromList(data)));
    });
  });
}
