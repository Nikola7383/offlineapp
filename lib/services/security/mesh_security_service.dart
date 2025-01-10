class MeshSecurityService {
  final SecurityService _security;
  final LoggerService _logger;
  final _keyPairs = <String, AsymmetricKeyPair>{};

  MeshSecurityService({
    required SecurityService security,
    required LoggerService logger,
  })  : _security = security,
        _logger = logger;

  Future<SecureMessage> prepareMessageForTransmission(Message message) async {
    try {
      // 1. Generišemo jedinstveni AES ključ za poruku
      final messageKey = await _generateMessageKey();

      // 2. Enkriptujemo sadržaj poruke
      final encryptedContent =
          await _encryptContent(message.content, messageKey);

      // 3. Enkriptujemo AES ključ sa javnim ključem primaoca
      final encryptedKey =
          await _encryptMessageKey(messageKey, message.senderId);

      // 4. Generišemo potpis
      final signature = await _signMessage(encryptedContent);

      return SecureMessage(
        originalMessage: message,
        encryptedContent: encryptedContent,
        encryptedKey: encryptedKey,
        signature: signature,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      _logger.error('Message preparation failed: $e');
      throw SecurityException('Failed to prepare message');
    }
  }

  Future<bool> verifyAndDecryptMessage(SecureMessage secureMessage) async {
    try {
      // 1. Verifikujemo potpis
      if (!await _verifySignature(
          secureMessage.encryptedContent, secureMessage.signature)) {
        _logger.warning('Signature verification failed');
        return false;
      }

      // 2. Dekriptujemo message key
      final messageKey = await _decryptMessageKey(secureMessage.encryptedKey);

      // 3. Dekriptujemo sadržaj
      final decryptedContent =
          await _decryptContent(secureMessage.encryptedContent, messageKey);

      // 4. Verifikujemo integritet
      return await _verifyMessageIntegrity(secureMessage, decryptedContent);
    } catch (e) {
      _logger.error('Message verification failed: $e');
      return false;
    }
  }

  // Pomoćne metode za kriptografiju
  Future<List<int>> _generateMessageKey() async {
    final key = await _security.generateSecureKey();
    return key;
  }

  Future<String> _encryptContent(String content, List<int> key) async {
    // AES enkripcija
    return await _security.encryptAES(content, key);
  }

  Future<String> _signMessage(String content) async {
    // ED25519 potpis
    return await _security.sign(content);
  }
}
