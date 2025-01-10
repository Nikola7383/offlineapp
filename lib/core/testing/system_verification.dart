class SystemVerification {
  final SystemLogger _logger;
  final EncryptionService _encryption;
  final SeedManager _seeds;

  SystemVerification({
    required SystemLogger logger,
    required EncryptionService encryption,
    required SeedManager seeds,
  })  : _logger = logger,
        _encryption = encryption,
        _seeds = seeds;

  Future<void> verifyFixes() async {
    try {
      _logger.info('\n=== VERIFIKACIJA POPRAVKI ===\n');

      // 1. Proveri logging
      final loggerWorks = await _verifyLogger();
      _logger.info('Logger status: ${loggerWorks ? "✅" : "❌"}');

      // 2. Proveri encryption
      final encryptionWorks = await _verifyEncryption();
      _logger.info('Encryption status: ${encryptionWorks ? "✅" : "❌"}');

      // 3. Proveri seed sistem
      final seedsWork = await _verifySeeds();
      _logger.info('Seed system status: ${seedsWork ? "✅" : "❌"}');

      // Finalni izveštaj
      _logger.info('''
\n=== REZULTATI VERIFIKACIJE ===
Logger: ${loggerWorks ? "RADI" : "NE RADI"}
Encryption: ${encryptionWorks ? "RADI" : "NE RADI"}
Seed System: ${seedsWork ? "RADI" : "NE RADI"}

${_generateSummary(loggerWorks, encryptionWorks, seedsWork)}
''');
    } catch (e) {
      throw VerificationException('Verification failed: $e');
    }
  }
}
