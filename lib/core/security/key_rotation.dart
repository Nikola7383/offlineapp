@injectable
class KeyRotationManager extends InjectableService implements Disposable {
  static const ROTATION_INTERVAL = Duration(days: 1);
  final EncryptionService _encryption;
  Timer? _rotationTimer;

  KeyRotationManager(
    LoggerService logger,
    this._encryption,
  ) : super(logger);

  @override
  Future<void> initialize() async {
    await super.initialize();
    await _initializeKeys();
    _startRotationSchedule();
  }

  Future<void> _initializeKeys() async {
    if (!await _hasValidKeys()) {
      await _generateNewKeys();
    }
  }

  void _startRotationSchedule() {
    _rotationTimer = Timer.periodic(
      ROTATION_INTERVAL,
      (_) => _rotateKeys(),
    );
  }

  Future<void> _rotateKeys() async {
    try {
      final newKeys = await _generateNewKeys();
      await _encryption.updateKeys(newKeys);
      logger.info('Key rotation completed successfully');
    } catch (e, stack) {
      logger.error('Key rotation failed', e, stack);
    }
  }

  @override
  Future<void> dispose() async {
    _rotationTimer?.cancel();
    await super.dispose();
  }
}
