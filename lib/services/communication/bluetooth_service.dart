class BluetoothService {
  final BluetoothAdapter _adapter;
  final SecurityService _security;
  final LoggerService _logger;

  BluetoothService({
    required BluetoothAdapter adapter,
    required SecurityService security,
    required LoggerService logger,
  })  : _adapter = adapter,
        _security = security,
        _logger = logger;

  Future<void> initialize(
      {required BluetoothConfig config,
      required Function onConnected,
      required Function onError}) async {
    try {
      // Inicijalizuj adapter
      await _adapter.initialize();

      // Postavi BLE mode ako je podržan
      if (await _adapter.supportsBLE) {
        await _adapter.enableBLE();
      }

      // Postavi secure mode
      await _security.secureChannel(_adapter);

      // Započni scanning
      await _startScanning();
    } catch (e) {
      _logger.error('Bluetooth inicijalizacija nije uspela: $e');
      onError(e);
    }
  }

  Future<bool> send(EncryptedMessage message,
      {bool retryOnFail = true,
      Duration timeout = const Duration(seconds: 10)}) async {
    try {
      // Proveri konekciju
      if (!await _adapter.isConnected) {
        await _reconnect();
      }

      // Pošalji poruku
      final success = await _adapter.send(message, timeout: timeout);

      // Retry ako je potrebno
      if (!success && retryOnFail) {
        return await _retryTransmission(message);
      }

      return success;
    } catch (e) {
      _logger.error('Bluetooth slanje nije uspelo: $e');
      return false;
    }
  }
}
