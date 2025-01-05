/// Osnovni interfejs koji definišu svi servisi
abstract class IService {
  /// Status servisa
  bool get isInitialized;

  /// Inicijalizuje servis
  Future<void> initialize();

  /// Cleanup resursa
  Future<void> dispose();
}

abstract class BaseService implements IService {
  bool _isInitialized = false;

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    await onInitialize();
    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    if (!_isInitialized) return;
    await onDispose();
    _isInitialized = false;
  }

  Future<void> onInitialize() async {}
  Future<void> onDispose() async {}
}
