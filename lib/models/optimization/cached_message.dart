class CachedMessage {
  final SecureMessage message;
  final DateTime cachedAt;
  bool _isDisposed = false;

  CachedMessage({
    required this.message,
  }) : cachedAt = DateTime.now();

  bool get isExpired =>
      DateTime.now().difference(cachedAt) > PerformanceService.CACHE_TTL;

  void dispose() {
    if (!_isDisposed) {
      // Clean up resources
      _isDisposed = true;
    }
  }
}

class RollingAverage {
  final int windowSize;
  final Queue<int> _values = Queue();
  double _sum = 0;

  RollingAverage({required this.windowSize});

  void add(int value) {
    _sum += value;
    _values.add(value);

    if (_values.length > windowSize) {
      _sum -= _values.removeFirst();
    }
  }

  double get average => _values.isEmpty ? 0 : _sum / _values.length;
}
