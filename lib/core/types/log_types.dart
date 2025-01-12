/// Tipovi za logovanje
enum LogLevel { info, warning, error, critical }

/// Predstavlja jednu log poruku
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final Map<String, dynamic>? metadata;

  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.metadata,
  });
}
