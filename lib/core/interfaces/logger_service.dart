import 'base_service.dart';

/// Interfejs za logovanje
abstract class ILoggerService implements IService {
  /// Loguje debug poruku
  void debug(String message, [Object? error, StackTrace? stackTrace]);

  /// Loguje info poruku
  void info(String message, [Object? error, StackTrace? stackTrace]);

  /// Loguje warning poruku
  void warning(String message, [Object? error, StackTrace? stackTrace]);

  /// Loguje error poruku
  void error(String message, [Object? error, StackTrace? stackTrace]);

  /// Loguje kritičnu poruku
  void critical(String message, [Object? error, StackTrace? stackTrace]);

  /// Vraća sve logove
  Future<List<Map<String, dynamic>>> getLogs();
}

/// Nivoi logovanja
enum LogLevel {
  /// Debug nivo - za development
  debug,

  /// Info nivo - standardne informacije
  info,

  /// Warning nivo - upozorenja
  warning,

  /// Error nivo - greške
  error,

  /// Critical nivo - kritične greške
  critical
}

/// Log zapis
class LogEntry {
  /// Vreme logovanja
  final DateTime timestamp;

  /// Nivo loga
  final LogLevel level;

  /// Poruka
  final String message;

  /// Greška (opciono)
  final Object? error;

  /// Stack trace (opciono)
  final StackTrace? stackTrace;

  /// Kreira novi log zapis
  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.error,
    this.stackTrace,
  });
}
