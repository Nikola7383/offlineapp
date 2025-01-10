class DatabaseConnectionFix {
  final DatabaseService _db;
  final LoggerService _logger;
  final ConnectionPool _pool;
  
  // Connection monitoring
  final Map<String, ConnectionMetrics> _connectionMetrics = {};
  final Set<String> _activeConnections = {};
  
  DatabaseConnectionFix({
    required DatabaseService db,
    required LoggerService logger,
    required ConnectionPool pool,
  }) : _db = db,
       _logger = logger,
       _pool = pool {
    _initializeConnectionMonitoring();
  }

  Future<void> fixConnectionIssues() async {
    try {
      _logger.info('Starting database connection fix...');
      
      // 1. Kill zombie connections
      await _killZombieConnections();
      
      // 2. Reset connection pool
      await _resetConnectionPool();
      
      // 3. Reestablish healthy connections
      await _reestablishConnections();
      
      // 4. Verify fixes
      await _verifyConnections();
      
    } catch (e) {
      _logger.error('Connection fix failed: $e');
      throw FixException('Database connection fix failed');
    }
  }

  Future<void> _killZombieConnections() async {
    final zombies = _connectionMetrics.entries
      .where((e) => e.value.isZombie)
      .map((e) => e.key)
      .toList();

    for (final connId in zombies) {
      await _pool.forceCloseConnection(connId);
      _activeConnections.remove(connId);
    }
  }

  Future<void> _resetConnectionPool() async {
    await _pool.drain();
    await _pool.initialize(
      minConnections: 5,
      maxConnections: 20,
      idleTimeout: Duration(minutes: 5),
    );
  }
} 