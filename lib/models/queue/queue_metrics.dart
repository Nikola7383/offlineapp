class QueueMetrics {
  int _totalEnqueued = 0;
  int _totalProcessed = 0;
  int _failedMessages = 0;
  int _batchesProcessed = 0;
  final DateTime _startTime = DateTime.now();

  void messageEnqueued() => _totalEnqueued++;
  void messageProcessed() => _totalProcessed++;
  void messageFailed() => _failedMessages++;
  void batchProcessed() => _batchesProcessed++;

  double get throughput {
    final duration = DateTime.now().difference(_startTime).inSeconds;
    if (duration == 0) return 0;
    return _totalProcessed / duration;
  }

  double get failureRate {
    if (_totalProcessed == 0) return 0;
    return _failedMessages / _totalProcessed;
  }

  Map<String, dynamic> toMap() => {
        'totalEnqueued': _totalEnqueued,
        'totalProcessed': _totalProcessed,
        'failedMessages': _failedMessages,
        'batchesProcessed': _batchesProcessed,
        'throughput': throughput,
        'failureRate': failureRate,
      };
}
