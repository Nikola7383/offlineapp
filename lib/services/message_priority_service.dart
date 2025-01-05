class MessagePriorityService {
  final DatabaseService _db;
  final LoggerService _logger;

  MessagePriorityService({
    required DatabaseService db,
    required LoggerService logger,
  })  : _db = db,
        _logger = logger;

  // Određivanje prioriteta poruke
  int calculatePriority(Message message) {
    int priority = 0;

    // Hitne poruke imaju najveći prioritet
    if (message.isUrgent) priority += 100;

    // Admin poruke imaju veći prioritet
    if (message.sender.role == UserRole.admin) priority += 50;
    if (message.sender.role == UserRole.seed) priority += 30;

    // Novije poruke imaju veći prioritet
    final age = DateTime.now().difference(message.timestamp).inHours;
    priority += (24 - age).clamp(0, 24); // Max 24 poena za svežinu

    return priority;
  }

  // Dobavljanje poruka po prioritetu
  Future<List<Message>> getPrioritizedMessages() async {
    try {
      final messages = await _db.getAllMessages();
      messages
          .sort((a, b) => calculatePriority(b).compareTo(calculatePriority(a)));
      return messages;
    } catch (e) {
      _logger.error('Greška pri prioritizaciji: $e');
      return [];
    }
  }
}
