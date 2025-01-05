@injectable
class SystemHealth extends InjectableService {
  final DatabaseService _db;
  final MeshNetwork _network;
  final CacheManager _cache;
  final SecurityService _security;

  final _healthSubject = BehaviorSubject<HealthStatus>();
  Stream<HealthStatus> get healthStream => _healthSubject.stream;

  SystemHealth(
    LoggerService logger,
    this._db,
    this._network,
    this._cache,
    this._security,
  ) : super(logger);

  Future<HealthStatus> checkAll() async {
    final issues = <HealthIssue>[];

    try {
      // Paralelno izvršavamo sve health checkove
      await Future.wait([
        _checkDatabase().then((dbIssues) => issues.addAll(dbIssues)),
        _checkNetwork().then((netIssues) => issues.addAll(netIssues)),
        _checkCache().then((cacheIssues) => issues.addAll(cacheIssues)),
        _checkSecurity().then((secIssues) => issues.addAll(secIssues)),
      ]);

      final status = HealthStatus(
        timestamp: DateTime.now(),
        issues: issues,
        metrics: await _collectMetrics(),
      );

      _healthSubject.add(status);
      return status;
    } catch (e, stack) {
      logger.error('Health check failed', e, stack);
      throw HealthCheckException('Failed to complete health check');
    }
  }

  Future<List<HealthIssue>> _checkDatabase() async {
    final issues = <HealthIssue>[];

    // Provera konekcije
    if (!await _db.isConnected()) {
      issues.add(HealthIssue(
        type: HealthIssueType.database,
        severity: IssueSeverity.critical,
        message: 'Database connection lost',
        component: 'DatabaseService',
      ));
    }

    // Provera performansi
    final queryTime = await _db.measureQueryTime();
    if (queryTime > Duration(milliseconds: 100)) {
      issues.add(HealthIssue(
        type: HealthIssueType.performance,
        severity: IssueSeverity.warning,
        message: 'Database queries are slow',
        component: 'DatabaseService',
        metrics: {'queryTime': queryTime.inMilliseconds},
      ));
    }

    return issues;
  }

  Future<List<HealthIssue>> _checkNetwork() async {
    final issues = <HealthIssue>[];

    // Provera peer konekcija
    final peers = await _network.getConnectedPeers();
    if (peers.isEmpty) {
      issues.add(HealthIssue(
        type: HealthIssueType.network,
        severity: IssueSeverity.high,
        message: 'No connected peers',
        component: 'MeshNetwork',
      ));
    }

    // Provera latencije
    for (final peer in peers) {
      final latency = await _network.measureLatency(peer.id);
      if (latency > Duration(milliseconds: 200)) {
        issues.add(HealthIssue(
          type: HealthIssueType.performance,
          severity: IssueSeverity.warning,
          message: 'High latency with peer: ${peer.id}',
          component: 'MeshNetwork',
          metrics: {'latency': latency.inMilliseconds},
        ));
      }
    }

    return issues;
  }

  Future<Map<String, dynamic>> _collectMetrics() async {
    return {
      'memory': await _getMemoryMetrics(),
      'cpu': await _getCPUMetrics(),
      'network': await _getNetworkMetrics(),
      'storage': await _getStorageMetrics(),
    };
  }
}

class HealthStatus {
  final DateTime timestamp;
  final List<HealthIssue> issues;
  final Map<String, dynamic> metrics;

  HealthStatus({
    required this.timestamp,
    required this.issues,
    required this.metrics,
  });

  bool get needsAttention => issues.isNotEmpty;

  bool get hasCriticalIssues =>
      issues.any((issue) => issue.severity == IssueSeverity.critical);
}

enum HealthIssueType {
  database,
  network,
  security,
  performance,
  resource,
  cache
}

enum IssueSeverity { low, warning, high, critical }

class HealthIssue {
  final HealthIssueType type;
  final IssueSeverity severity;
  final String message;
  final String component;
  final Map<String, dynamic>? metrics;

  HealthIssue({
    required this.type,
    required this.severity,
    required this.message,
    required this.component,
    this.metrics,
  });
}
