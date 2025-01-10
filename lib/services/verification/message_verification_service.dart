class MessageVerificationService {
  final SecurityService _security;
  final DatabaseService _db;
  final LoggerService _logger;

  // Cache za već verifikovane poruke
  final Map<String, bool> _verificationCache = {};

  MessageVerificationService({
    required SecurityService security,
    required DatabaseService db,
    required LoggerService logger,
  })  : _security = security,
        _db = db,
        _logger = logger;

  Future<VerificationResult> verifyMessage(SecureMessage message) async {
    try {
      // 1. Proveri cache
      if (_verificationCache.containsKey(message.originalMessage.id)) {
        return VerificationResult(
          isValid: _verificationCache[message.originalMessage.id]!,
          message: message,
          verifiedAt: DateTime.now(),
        );
      }

      // 2. Verifikuj integritet poruke
      final integrityValid = await _verifyMessageIntegrity(message);
      if (!integrityValid) {
        return _failVerification(message, 'Integrity check failed');
      }

      // 3. Verifikuj potpis
      final signatureValid = await _verifySignature(message);
      if (!signatureValid) {
        return _failVerification(message, 'Signature verification failed');
      }

      // 4. Verifikuj timestamp
      final timestampValid = _verifyTimestamp(message);
      if (!timestampValid) {
        return _failVerification(message, 'Timestamp validation failed');
      }

      // 5. Verifikuj sender
      final senderValid = await _verifySender(message);
      if (!senderValid) {
        return _failVerification(message, 'Sender verification failed');
      }

      // Sve je prošlo, cache-iraj rezultat
      _verificationCache[message.originalMessage.id] = true;

      return VerificationResult(
        isValid: true,
        message: message,
        verifiedAt: DateTime.now(),
      );
    } catch (e) {
      _logger.error('Verification failed: $e');
      return _failVerification(message, 'Verification error: $e');
    }
  }

  Future<bool> _verifyMessageIntegrity(SecureMessage message) async {
    try {
      // Proveri hash
      final calculatedHash = await _security
          .calculateHash(message.encryptedContent + message.signature);
      return calculatedHash == message.originalMessage.signature;
    } catch (e) {
      _logger.error('Integrity check failed: $e');
      return false;
    }
  }

  Future<bool> _verifySignature(SecureMessage message) async {
    try {
      return await _security.verifySignature(message.encryptedContent,
          message.signature, message.originalMessage.senderId);
    } catch (e) {
      _logger.error('Signature verification failed: $e');
      return false;
    }
  }

  bool _verifyTimestamp(SecureMessage message) {
    final now = DateTime.now();
    final messageTime = message.timestamp;

    // Dozvoli poruke ±5 minuta od trenutnog vremena
    final difference = now.difference(messageTime).abs();
    return difference.inMinutes <= 5;
  }

  Future<bool> _verifySender(SecureMessage message) async {
    try {
      // Proveri da li je sender validan u bazi
      final sender = await _db.getUser(message.originalMessage.senderId);
      return sender != null && sender.isActive;
    } catch (e) {
      _logger.error('Sender verification failed: $e');
      return false;
    }
  }

  VerificationResult _failVerification(SecureMessage message, String reason) {
    _verificationCache[message.originalMessage.id] = false;
    _logger.warning('Message verification failed: $reason');

    return VerificationResult(
      isValid: false,
      message: message,
      verifiedAt: DateTime.now(),
      failureReason: reason,
    );
  }
}
