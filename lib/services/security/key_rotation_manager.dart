class KeyRotationManager {
  final EncryptionService _encryption;
  final LoggerService _logger;
  final AuditLoggingService _audit;

  // Key rotation settings
  static const Duration DEFAULT_ROTATION_INTERVAL = Duration(days: 30);
  static const int KEY_HISTORY_LENGTH = 3;

  KeyRotationManager({
    required EncryptionService encryption,
    required LoggerService logger,
    required AuditLoggingService audit,
  })  : _encryption = encryption,
        _logger = logger,
        _audit = audit;

  Future<void> rotateKeys() async {
    try {
      _logger.info('Starting key rotation...');

      // 1. Generiši nove ključeve
      final newKeys = await _encryption.generateNewKeys();

      // 2. Verifikuj nove ključeve
      await _verifyNewKeys(newKeys);

      // 3. Reencrypt podatke sa novim ključevima
      await _reencryptData(newKeys);

      // 4. Aktiviraj nove ključeve
      await _activateNewKeys(newKeys);

      // 5. Arhiviraj stare ključeve
      await _archiveOldKeys();

      // 6. Audit log
      await _audit.logSecurityEvent(
        eventType: 'key_rotation',
        userId: 'system',
        details: {'keyId': newKeys.id},
        level: SecurityLevel.critical,
      );
    } catch (e) {
      _logger.error('Key rotation failed: $e');
      throw SecurityException('Failed to rotate encryption keys');
    }
  }

  Future<void> _verifyNewKeys(EncryptionKeys keys) async {
    // 1. Proveri snagu ključeva
    if (!await _encryption.verifyKeyStrength(keys)) {
      throw SecurityException('New keys failed strength verification');
    }

    // 2. Test encryption/decryption
    final testData = await _encryption.encrypt(data: 'test', keys: keys);

    final decrypted = await _encryption.decrypt(data: testData, keys: keys);

    if (decrypted != 'test') {
      throw SecurityException('New keys failed encryption test');
    }
  }
}
