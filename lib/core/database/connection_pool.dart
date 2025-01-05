@injectable
class DatabasePool extends InjectableService implements Disposable {
  static const int MAX_CONNECTIONS = 5;
  final List<PooledConnection> _pool = [];
  final Queue<Completer<PooledConnection>> _waitQueue = Queue();
  final _mutex = Lock();

  DatabasePool(LoggerService logger) : super(logger);

  Future<T> withConnection<T>(Future<T> Function(Database) operation) async {
    final conn = await _acquireConnection();
    try {
      return await operation(conn.database);
    } finally {
      await _releaseConnection(conn);
    }
  }

  Future<PooledConnection> _acquireConnection() async {
    return await _mutex.synchronized(() async {
      // Prvo pokušaj naći slobodnu konekciju
      final available = _pool.firstWhere(
        (conn) => !conn.inUse,
        orElse: () => PooledConnection.empty(),
      );

      if (available.isValid) {
        available.inUse = true;
        return available;
      }

      // Ako nema slobodnih, a nismo dostigli limit, kreiraj novu
      if (_pool.length < MAX_CONNECTIONS) {
        final conn = await _createConnection();
        _pool.add(conn);
        return conn;
      }

      // Ako smo dostigli limit, čekaj da se oslobodi konekcija
      final completer = Completer<PooledConnection>();
      _waitQueue.add(completer);
      return completer.future;
    });
  }

  Future<void> _releaseConnection(PooledConnection conn) async {
    await _mutex.synchronized(() {
      conn.inUse = false;
      if (_waitQueue.isNotEmpty) {
        final completer = _waitQueue.removeFirst();
        completer.complete(conn);
      }
    });
  }
}

class PooledConnection {
  final Database database;
  bool inUse;
  final DateTime createdAt;

  PooledConnection({
    required this.database,
    this.inUse = false,
  }) : createdAt = DateTime.now();

  bool get isValid => database.isOpen;

  factory PooledConnection.empty() => PooledConnection(
        database: Database.empty(),
        inUse: false,
      );
}
