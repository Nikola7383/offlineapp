class SoundService {
  final SoundEngine _engine;
  final NoiseFilter _filter;
  final LoggerService _logger;

  SoundService({
    required SoundEngine engine,
    required NoiseFilter filter,
    required LoggerService logger,
  })  : _engine = engine,
        _filter = filter,
        _logger = logger;

  Future<void> initialize(
      {required SoundConfig config,
      required Function onReady,
      required Function onError}) async {
    try {
      // Inicijalizuj sound engine
      await _engine.initialize(
          frequency: config.frequency, amplification: config.amplification);

      // Postavi noise cancellation
      if (config.noiseCancellation) {
        await _filter.enable();
      }

      // Testiraj prenos
      await _testTransmission();
    } catch (e) {
      _logger.error('Sound inicijalizacija nije uspela: $e');
      onError(e);
    }
  }

  Future<bool> transmit(EncryptedMessage message,
      {required bool withErrorCorrection, required int frequency}) async {
    try {
      // Primeni noise filter
      final filteredMessage = await _filter.apply(message);

      // Kodiraj poruku
      final encodedMessage =
          await _engine.encode(filteredMessage, frequency: frequency);

      // Pošalji
      final success = await _engine.transmit(encodedMessage,
          withErrorCorrection: withErrorCorrection);

      return success;
    } catch (e) {
      _logger.error('Sound transmisija nije uspela: $e');
      return false;
    }
  }
}
