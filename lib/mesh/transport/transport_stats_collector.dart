import 'dart:async';
import 'message_transport.dart';

/// Prikuplja i analizira statistiku transporta
class TransportStatsCollector implements TransportStats {
  // Osnovne metrike
  int _messagesSent = 0;
  int _messagesReceived = 0;
  int _failedDeliveries = 0;

  // Latencija
  final List<double> _latencies = [];
  static const int MAX_LATENCY_SAMPLES = 100;

  // Jačina signala
  final List<double> _signalStrengths = [];
  static const int MAX_SIGNAL_SAMPLES = 50;

  // Vremenske metrike
  DateTime? _lastMessageTime;
  final List<Duration> _messageIntervals = [];
  static const int MAX_INTERVAL_SAMPLES = 50;

  // Veličine poruka
  final List<int> _messageSizes = [];
  static const int MAX_SIZE_SAMPLES = 50;

  // Konstante za izračunavanje proseka
  static const Duration STATS_WINDOW = Duration(minutes: 5);
  static const Duration OLD_STATS_THRESHOLD = Duration(minutes: 30);

  @override
  int get totalMessagesSent => _messagesSent;

  @override
  int get totalMessagesReceived => _messagesReceived;

  @override
  int get failedDeliveries => _failedDeliveries;

  @override
  double get averageLatency {
    _cleanOldStats();
    if (_latencies.isEmpty) return 0.0;
    return _latencies.reduce((a, b) => a + b) / _latencies.length;
  }

  @override
  double get averageSignalStrength {
    _cleanOldStats();
    if (_signalStrengths.isEmpty) return 0.0;
    return _signalStrengths.reduce((a, b) => a + b) / _signalStrengths.length;
  }

  @override
  double get deliverySuccessRate {
    if (_messagesSent == 0) return 0.0;
    return (_messagesSent - _failedDeliveries) / _messagesSent;
  }

  /// Prosečna veličina poruke u bajtovima
  double get averageMessageSize {
    if (_messageSizes.isEmpty) return 0.0;
    return _messageSizes.reduce((a, b) => a + b) / _messageSizes.length;
  }

  /// Prosečan interval između poruka
  Duration get averageMessageInterval {
    if (_messageIntervals.isEmpty) {
      return const Duration(seconds: 0);
    }
    final totalMs =
        _messageIntervals.map((d) => d.inMilliseconds).reduce((a, b) => a + b);
    return Duration(milliseconds: (totalMs / _messageIntervals.length).round());
  }

  /// Beleži uspešno slanje poruke
  void recordMessageSent(int size, {double? latency}) {
    _messagesSent++;
    _recordMessageSize(size);
    _recordMessageTime();
    if (latency != null) {
      _recordLatency(latency);
    }
  }

  /// Beleži primljenu poruku
  void recordMessageReceived(int size, {double? signalStrength}) {
    _messagesReceived++;
    _recordMessageSize(size);
    _recordMessageTime();
    if (signalStrength != null) {
      _recordSignalStrength(signalStrength);
    }
  }

  /// Beleži neuspelo slanje
  void recordFailedDelivery() {
    _failedDeliveries++;
  }

  /// Beleži latenciju
  void recordLatency(double latencyMs) {
    _recordLatency(latencyMs);
  }

  /// Beleži jačinu signala
  void recordSignalStrength(double strength) {
    _recordSignalStrength(strength);
  }

  @override
  void reset() {
    _messagesSent = 0;
    _messagesReceived = 0;
    _failedDeliveries = 0;
    _latencies.clear();
    _signalStrengths.clear();
    _messageIntervals.clear();
    _messageSizes.clear();
    _lastMessageTime = null;
  }

  /// Beleži veličinu poruke
  void _recordMessageSize(int size) {
    _messageSizes.add(size);
    if (_messageSizes.length > MAX_SIZE_SAMPLES) {
      _messageSizes.removeAt(0);
    }
  }

  /// Beleži vreme poruke i računa interval
  void _recordMessageTime() {
    final now = DateTime.now();
    if (_lastMessageTime != null) {
      final interval = now.difference(_lastMessageTime!);
      _messageIntervals.add(interval);
      if (_messageIntervals.length > MAX_INTERVAL_SAMPLES) {
        _messageIntervals.removeAt(0);
      }
    }
    _lastMessageTime = now;
  }

  /// Beleži latenciju
  void _recordLatency(double latencyMs) {
    _latencies.add(latencyMs);
    if (_latencies.length > MAX_LATENCY_SAMPLES) {
      _latencies.removeAt(0);
    }
  }

  /// Beleži jačinu signala
  void _recordSignalStrength(double strength) {
    _signalStrengths.add(strength);
    if (_signalStrengths.length > MAX_SIGNAL_SAMPLES) {
      _signalStrengths.removeAt(0);
    }
  }

  /// Čisti zastarele statistike
  void _cleanOldStats() {
    final now = DateTime.now();
    final threshold = now.subtract(OLD_STATS_THRESHOLD);

    // TODO: Implementirati čišćenje starih statistika po vremenu
    // Za sada samo održava maksimalnu veličinu lista
  }

  /// Kreira snapshot trenutne statistike
  Map<String, dynamic> createSnapshot() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'messagesSent': _messagesSent,
      'messagesReceived': _messagesReceived,
      'failedDeliveries': _failedDeliveries,
      'averageLatency': averageLatency,
      'averageSignalStrength': averageSignalStrength,
      'deliverySuccessRate': deliverySuccessRate,
      'averageMessageSize': averageMessageSize,
      'averageMessageInterval': averageMessageInterval.inMilliseconds,
    };
  }
}
