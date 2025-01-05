class KeyManager {
  static const String _masterKey = 'predefined_master_key_123';
  bool _isInitialized = false;

  Future<void> initialize() async {
    _isInitialized = true;
  }

  String getMasterKey() {
    if (!_isInitialized) throw Exception('KeyManager not initialized');
    return _masterKey;
  }

  bool get isInitialized => _isInitialized;
}
