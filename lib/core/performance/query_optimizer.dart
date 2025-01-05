@injectable
class QueryOptimizer extends InjectableService {
  final DatabaseService _db;
  final Map<String, QueryStatistics> _queryStats = {};

  QueryOptimizer(
    LoggerService logger,
    this._db,
  ) : super(logger);

  Future<void> optimizeQuery(String sql) async {
    final stats = _queryStats[sql];
    if (stats == null) return;

    if (stats.averageExecutionTime > 1000) {
      await _createIndexForQuery(sql);
    }

    if (stats.executionCount > 1000 && stats.cacheHitRatio < 0.5) {
      await _enableQueryCaching(sql);
    }
  }

  Future<void> _createIndexForQuery(String sql) async {
    final tables = _extractTables(sql);
    final columns = _extractColumns(sql);

    for (final table in tables) {
      for (final column in columns) {
        if (await _shouldCreateIndex(table, column)) {
          await _db.execute('''
            CREATE INDEX IF NOT EXISTS idx_${table}_${column}
            ON $table ($column)
          ''');

          logger.info('Created index on $table($column)');
        }
      }
    }
  }

  Future<bool> _shouldCreateIndex(String table, String column) async {
    // Proveri da li index već postoji
    final indexes = await _db.query(
      'sqlite_master',
      where: 'type = ? AND tbl_name = ?',
      whereArgs: ['index', table],
    );

    return !indexes.any((idx) => idx['sql'].toString().contains(column));
  }

  void recordQueryExecution(String sql, Duration executionTime) {
    _queryStats
        .putIfAbsent(sql, () => QueryStatistics())
        .recordExecution(executionTime);
  }
}

class QueryStatistics {
  int executionCount = 0;
  Duration totalExecutionTime = Duration.zero;
  int cacheHits = 0;

  void recordExecution(Duration executionTime) {
    executionCount++;
    totalExecutionTime += executionTime;
  }

  double get averageExecutionTime =>
      totalExecutionTime.inMilliseconds / executionCount;

  double get cacheHitRatio => cacheHits / executionCount;
}
