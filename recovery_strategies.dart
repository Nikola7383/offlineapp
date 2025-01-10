class RecoveryStrategy {
  final String name;
  final int priority;
  final Future<bool> Function() execute;

  RecoveryStrategy(
      {required this.name, required this.priority, required this.execute});
}

class RecoveryManager {
  final List<RecoveryStrategy> strategies;
  DateTime? _lastAttemptTime;
  bool? _lastAttemptResult;
  String? _lastAttemptStrategy;

  RecoveryManager(this.strategies);

  void addStrategy(RecoveryStrategy strategy) {
    strategies.add(strategy);
    strategies.sort((a, b) => a.priority.compareTo(b.priority));
  }

  Map<String, dynamic> getLastAttemptStatus() {
    return {
      'timestamp': _lastAttemptTime?.toIso8601String(),
      'success': _lastAttemptResult,
      'strategy': _lastAttemptStrategy,
    };
  }

  Future<bool> attemptRecovery() async {
    final sortedStrategies = strategies
      ..sort((a, b) => a.priority.compareTo(b.priority));

    _lastAttemptTime = DateTime.now();
    _lastAttemptResult = false;
    _lastAttemptStrategy = null;

    for (final strategy in sortedStrategies) {
      try {
        final result = await strategy.execute();
        if (result) {
          _lastAttemptResult = true;
          _lastAttemptStrategy = strategy.name;
          return true;
        }
      } catch (e) {
        // Nastavljamo sa sledećom strategijom u slučaju greške
        continue;
      }
    }
    return false;
  }
}
