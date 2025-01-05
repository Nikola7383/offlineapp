@injectable
class RecoveryManager extends InjectableService {
  final Map<String, RecoveryStrategy> _strategies = {};
  final Queue<RecoveryAction> _pendingRecoveries = Queue();

  void registerStrategy(String errorType, RecoveryStrategy strategy) {
    _strategies[errorType] = strategy;
  }

  Future<void> handleError(dynamic error) async {
    final strategy = _findStrategy(error);
    if (strategy != null) {
      final action = await strategy.createRecoveryAction(error);
      _pendingRecoveries.add(action);
      await _executeRecovery(action);
    } else {
      logger.error('No recovery strategy for error', error);
    }
  }

  Future<void> _executeRecovery(RecoveryAction action) async {
    try {
      await action.execute();
      _pendingRecoveries.remove(action);
    } catch (e) {
      logger.error('Recovery failed', e);
      if (action.canRetry) {
        _pendingRecoveries.add(action..incrementRetry());
      }
    }
  }
}
