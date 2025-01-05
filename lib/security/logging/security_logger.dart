import 'dart:async';

class SecurityLogger {
  static final SecurityLogger _instance = SecurityLogger._internal();

  final StreamController<LogEntry> _logStream = StreamController.broadcast();
  final List<LogEntry> _logBuffer = [];
  final int _maxBufferSize = 1000;

  factory SecurityLogger() {
    return _instance;
  }

  SecurityLogger._internal() {
    _initializeLogger();
  }

  void _initializeLogger() {
    _logStream.stream.listen((entry) {
      _bufferLog(entry);
    });
  }

  Future<void> logError(SecurityError error) async {
    final entry = LogEntry(
        level: LogLevel.error,
        message: error.message,
        data: error.toMap(),
        timestamp: DateTime.now());

    await _logEntry(entry);
  }

  Future<void> logWarning(String message, [Map<String, dynamic>? data]) async {
    final entry = LogEntry(
        level: LogLevel.warning,
        message: message,
        data: data,
        timestamp: DateTime.now());

    await _logEntry(entry);
  }

  Future<void> logInfo(String message, [Map<String, dynamic>? data]) async {
    final entry = LogEntry(
        level: LogLevel.info,
        message: message,
        data: data,
        timestamp: DateTime.now());

    await _logEntry(entry);
  }

  Future<void> _logEntry(LogEntry entry) async {
    try {
      _logStream.add(entry);

      if (entry.level == LogLevel.error) {
        // Dodatno logovanje za greške
        await _handleErrorLog(entry);
      }
    } catch (e) {
      print('Critical error in logger: $e');
    }
  }

  void _bufferLog(LogEntry entry) {
    _logBuffer.add(entry);

    if (_logBuffer.length > _maxBufferSize) {
      _logBuffer.removeAt(0);
    }
  }

  Future<void> _handleErrorLog(LogEntry entry) async {
    // Implementacija dodatnog rukovanja greškama
  }

  List<LogEntry> getRecentLogs([int count = 100]) {
    return _logBuffer.reversed.take(count).toList();
  }

  Stream<LogEntry> get logStream => _logStream.stream;
}

class LogEntry {
  final LogLevel level;
  final String message;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  LogEntry(
      {required this.level,
      required this.message,
      this.data,
      required this.timestamp});
}

enum LogLevel { debug, info, warning, error, critical }
