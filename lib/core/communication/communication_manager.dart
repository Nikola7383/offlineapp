class CommunicationManager {
  final BluetoothService _bluetooth;
  final SoundService _sound;
  final MeshService _mesh;
  final LoggerService _logger;
  final SecurityService _security;

  CommunicationManager({
    required BluetoothService bluetooth,
    required SoundService sound,
    required MeshService mesh,
    required LoggerService logger,
    required SecurityService security,
  })  : _bluetooth = bluetooth,
        _sound = sound,
        _mesh = mesh,
        _logger = logger,
        _security = security;

  Future<void> initializeAllChannels() async {
    try {
      _logger.info('Inicijalizacija komunikacionih kanala...');

      // Paralelno inicijalizuj sve kanale
      await Future.wait(
          [_initializeBluetooth(), _initializeSound(), _initializeMesh()]);

      // Postavi fallback mehanizme
      await _setupFallbackMechanisms();

      // Postavi monitoring
      await _setupChannelMonitoring();
    } catch (e) {
      _logger.error('Inicijalizacija komunikacije nije uspela: $e');
      throw CommunicationException('Failed to initialize communication');
    }
  }

  Future<void> _initializeBluetooth() async {
    await _bluetooth.initialize(
        config: BluetoothConfig(
            retryAttempts: 3,
            connectionTimeout: Duration(seconds: 30),
            enableBLE: true,
            secureMode: true),
        onConnected: _handleBluetoothConnection,
        onError: _handleBluetoothError);
  }

  Future<void> _initializeSound() async {
    await _sound.initialize(
        config: SoundConfig(
            frequency: 18000, // Optimizovana frekvencija
            amplification: 1.5,
            noiseCancellation: true,
            errorCorrection: true),
        onReady: _handleSoundReady,
        onError: _handleSoundError);
  }

  Future<void> _initializeMesh() async {
    await _mesh.initialize(
        config: MeshConfig(
            nodeCapacity: 100,
            autoReconnect: true,
            messageRetry: true,
            secureRouting: true),
        onNetworkReady: _handleMeshReady,
        onError: _handleMeshError);
  }

  Future<void> sendMessage(Message message) async {
    try {
      // Enkriptuj poruku
      final encryptedMessage = await _security.encrypt(message);

      // Pokušaj slanje preko svih kanala
      final results = await Future.wait([
        _sendViaBluetooth(encryptedMessage),
        _sendViaSound(encryptedMessage),
        _sendViaMesh(encryptedMessage)
      ]);

      // Proveri rezultate
      if (!results.any((success) => success)) {
        throw CommunicationException('All channels failed');
      }
    } catch (e) {
      _logger.error('Slanje poruke nije uspelo: $e');
      throw MessageException('Failed to send message');
    }
  }

  Future<bool> _sendViaBluetooth(EncryptedMessage message) async {
    try {
      return await _bluetooth.send(message,
          retryOnFail: true, timeout: Duration(seconds: 10));
    } catch (e) {
      _logger.error('Bluetooth slanje nije uspelo: $e');
      return false;
    }
  }

  Future<bool> _sendViaSound(EncryptedMessage message) async {
    try {
      return await _sound.transmit(message,
          withErrorCorrection: true, frequency: 18000);
    } catch (e) {
      _logger.error('Sound prenos nije uspeo: $e');
      return false;
    }
  }

  Future<bool> _sendViaMesh(EncryptedMessage message) async {
    try {
      return await _mesh.broadcast(message,
          priority: Priority.high, redundancy: true);
    } catch (e) {
      _logger.error('Mesh broadcast nije uspeo: $e');
      return false;
    }
  }
}
