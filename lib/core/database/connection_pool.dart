import 'dart:async';
import 'dart:collection';
import 'package:injectable/injectable.dart';
import 'package:synchronized/synchronized.dart';
import '../interfaces/database_pool_interface.dart';
import '../interfaces/logger_service_interface.dart';
import 'database.dart';

/// Implementacija pool-a database konekcija
///
/// Ova klasa obezbeđuje:
/// - Thread-safe pristup konekcijama
/// - Ograničen broj konekcija
/// - Automatsko oslobađanje resursa
/// - Čekanje na slobodnu konekciju kada je pool pun
@injectable
class DatabasePool implements IDatabasePool {
  final List<PooledConnection> _pool = [];
  final Queue<Completer<PooledConnection>> _waitQueue = Queue();
  final Lock _mutex = Lock();
  final ILoggerService _logger;
  bool _isInitialized = false;

  DatabasePool(this._logger);

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    await _logger.info('DatabasePool initialized');
  }

  @override
  Future<T> withConnection<T>(Future<T> Function(Database) operation) async {
    final conn = await _acquireConnection();
    try {
      return await operation(conn.database);
    } finally {
      await _releaseConnection(conn);
    }
  }

  @override
  int get activeConnections => _pool.where((conn) => conn.inUse).length;

  @override
  int get waitingConnections => _waitQueue.length;

  @override
  bool get isFull => _pool.length >= IDatabasePool.MAX_CONNECTIONS;

  Future<PooledConnection> _acquireConnection() async {
    return await _mutex.synchronized(() async {
      // Prvo pokušaj naći slobodnu konekciju
      final available = _pool.firstWhere(
        (conn) => !conn.inUse,
        orElse: () => PooledConnection.empty(),
      );

      if (available.isValid) {
        available.inUse = true;
        await _logger.info('Acquired existing connection');
        return available;
      }

      // Ako nema slobodnih, a nismo dostigli limit, kreiraj novu
      if (!isFull) {
        final conn = await _createConnection();
        _pool.add(conn);
        await _logger.info('Created new connection');
        return conn;
      }

      // Ako smo dostigli limit, čekaj da se oslobodi konekcija
      await _logger
          .warning('Connection pool is full, waiting for available connection');
      final completer = Completer<PooledConnection>();
      _waitQueue.add(completer);
      return completer.future;
    });
  }

  Future<void> _releaseConnection(PooledConnection conn) async {
    await _mutex.synchronized(() async {
      conn.inUse = false;
      if (_waitQueue.isNotEmpty) {
        final completer = _waitQueue.removeFirst();
        completer.complete(conn);
        await _logger.info('Released connection to waiting client');
      } else {
        await _logger.info('Released connection back to pool');
      }
    });
  }

  Future<PooledConnection> _createConnection() async {
    final database = await Database.open();
    return PooledConnection(database: database);
  }

  @override
  Future<void> dispose() async {
    await _mutex.synchronized(() async {
      for (var conn in _pool) {
        await conn.database.close();
      }
      _pool.clear();
      _waitQueue.clear();
      _isInitialized = false;
      await _logger.info('DatabasePool disposed');
    });
  }
}

/// Reprezentuje jednu konekciju u pool-u
///
/// Sadrži:
/// - Referencu na database konekciju
/// - Status korišćenja
/// - Vreme kreiranja
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
