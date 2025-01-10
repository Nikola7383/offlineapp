class OptimizedDatabaseService {
  final Database _db;
  final LoggerService _logger;
  final CacheService _cache;

  // Indeksi i query optimizacije
  static const Map<String, String> INDEXES = {
    'messages':
        'CREATE INDEX IF NOT EXISTS idx_messages_timestamp ON messages(timestamp)',
    'users':
        'CREATE INDEX IF NOT EXISTS idx_users_last_active ON users(last_active)',
    'peers': 'CREATE INDEX IF NOT EXISTS idx_peers_status ON peers(status)',
  };

  OptimizedDatabaseService({
    required Database db,
    required LoggerService logger,
    required CacheService cache,
  })  : _db = db,
        _logger = logger,
        _cache = cache {
    _initializeOptimizations();
  }

  Future<void> _initializeOptimizations() async {
    // 1. Kreiraj indekse
    await _createIndexes();

    // 2. Optimizuj query planove
    await _optimizeQueryPlans();

    // 3. Podesi write-ahead logging
    await _enableWAL();

    // 4. Inicijalizuj cache
    await _initializeCache();
  }

  Future<void> saveMessage(Message message) async {
    final batch = _db.batch();
    try {
      // 1. Cache check
      if (await _cache.has(message.id)) return;

      // 2. Batch write
      batch.insert('messages', message.toMap());
      batch.update('stats', {'last_message_time': DateTime.now()});

      await batch.commit();

      // 3. Update cache
      await _cache.set(message.id, message);
    } catch (e) {
      await batch.rollback();
      _logger.error('Failed to save message: $e');
      throw DatabaseException('Save failed');
    }
  }

  Future<List<Message>> getRecentMessages({
    int limit = 100,
    Duration age = const Duration(hours: 1),
  }) async {
    try {
      final cacheKey = 'recent_messages_$limit';

      // 1. Check cache
      final cached = await _cache.get(cacheKey);
      if (cached != null) return cached;

      // 2. Optimized query
      final results = await _db.query(
        'messages',
        where: 'timestamp > ?',
        whereArgs: [DateTime.now().subtract(age).millisecondsSinceEpoch],
        orderBy: 'timestamp DESC',
        limit: limit,
      );

      final messages = results.map((r) => Message.fromMap(r)).toList();

      // 3. Update cache
      await _cache.set(cacheKey, messages, ttl: Duration(minutes: 5));

      return messages;
    } catch (e) {
      _logger.error('Failed to get recent messages: $e');
      throw DatabaseException('Query failed');
    }
  }
}
