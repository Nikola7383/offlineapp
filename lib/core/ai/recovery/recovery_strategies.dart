@injectable
class RecoveryStrategyManager extends InjectableService {
  final Map<HealthIssueType, List<RecoveryStrategy>> _strategies = {};
  final _recoveryResults = StreamController<RecoveryResult>.broadcast();

  Stream<RecoveryResult> get results => _recoveryResults.stream;

  RecoveryStrategyManager(LoggerService logger) : super(logger) {
    _registerDefaultStrategies();
  }

  void _registerDefaultStrategies() {
    // Database Recovery Strategies
    registerStrategy(
      HealthIssueType.database,
      DatabaseReconnectionStrategy(),
    );
    registerStrategy(
      HealthIssueType.database,
      DatabaseCleanupStrategy(),
    );

    // Network Recovery Strategies
    registerStrategy(
      HealthIssueType.network,
      NetworkReconnectionStrategy(),
    );
    registerStrategy(
      HealthIssueType.network,
      PeerDiscoveryStrategy(),
    );

    // Cache Recovery Strategies
    registerStrategy(
      HealthIssueType.cache,
      CacheEvictionStrategy(),
    );
    registerStrategy(
      HealthIssueType.cache,
      CacheResyncStrategy(),
    );

    // Security Recovery Strategies
    registerStrategy(
      HealthIssueType.security,
      KeyRotationStrategy(),
    );
    registerStrategy(
      HealthIssueType.security,
      SessionResetStrategy(),
    );
  }

  void registerStrategy(HealthIssueType type, RecoveryStrategy strategy) {
    _strategies.putIfAbsent(type, () => []).add(strategy);
  }

  Future<RecoveryResult> attemptRecovery(HealthIssue issue) async {
    final strategies = _strategies[issue.type] ?? [];
    if (strategies.isEmpty) {
      return RecoveryResult(
        successful: false,
        message: 'No recovery strategies available for ${issue.type}',
      );
    }

    RecoveryResult? result;
    for (final strategy in strategies) {
      try {
        result = await strategy.execute(issue);
        if (result.successful) break;
      } catch (e, stack) {
        logger.error(
          'Recovery strategy ${strategy.runtimeType} failed',
          e,
          stack,
        );
      }
    }

    final finalResult = result ??
        RecoveryResult(
          successful: false,
          message: 'All recovery attempts failed',
        );

    _recoveryResults.add(finalResult);
    return finalResult;
  }
}

abstract class RecoveryStrategy {
  Future<RecoveryResult> execute(HealthIssue issue);
}

class RecoveryResult {
  final bool successful;
  final String message;
  final Map<String, dynamic>? metrics;

  RecoveryResult({
    required this.successful,
    required this.message,
    this.metrics,
  });
}
