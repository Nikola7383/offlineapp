class LocalBroadcastService {
  final DatabaseService _db;
  final LoggerService _logger;
  final MeshNetworkService _mesh;

  LocalBroadcastService({
    required DatabaseService db,
    required LoggerService logger,
    required MeshNetworkService mesh,
  })  : _db = db,
        _logger = logger,
        _mesh = mesh;

  // Slanje poruke lokalno i preko mesh mreže
  Future<void> broadcastMessage(Message message) async {
    try {
      // Sačuvaj lokalno
      await _db.saveMessage(message);

      // Pokušaj da pošalješ preko mesh mreže
      await _mesh.startAdvertising();
      await _mesh.startDiscovery();
    } catch (e) {
      _logger.error('Greška pri broadcast-u: $e');
    }
  }

  // Primanje poruka od drugih uređaja
  Future<void> handleIncomingMessage(Message message) async {
    try {
      // Proveri da li već imamo ovu poruku
      final exists = await _db.messageExists(message.id);
      if (!exists) {
        await _db.saveMessage(message);
        // Propagiraj dalje kroz mesh mrežu
        await _mesh.startAdvertising();
      }
    } catch (e) {
      _logger.error('Greška pri primanju poruke: $e');
    }
  }

  // Čišćenje duplikata
  Future<void> deduplicateMessages() async {
    try {
      await _db.removeDuplicateMessages();
    } catch (e) {
      _logger.error('Greška pri deduplikaciji: $e');
    }
  }
}
