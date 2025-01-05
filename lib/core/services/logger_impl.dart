import 'dart:developer' as developer;
import '../interfaces/logger.dart';
import '../config/app_config.dart';

class LoggerImpl implements Logger {
  final bool enableDebugLogs;
  final String prefix;

  const LoggerImpl({
    this.enableDebugLogs = AppConfig.enableDebugLogs,
    this.prefix = AppConfig.logPrefix,
  });

  @override
  Future<void> debug(String message, [Map<String, dynamic>? context]) async {
    if (!enableDebugLogs) return;
    _log(
      message,
      level: 'DEBUG',
      context: context,
      color: '\x1B[36m', // Cyan
    );
  }

  @override
  Future<void> info(String message, [Map<String, dynamic>? context]) async {
    _log(
      message,
      level: 'INFO',
      context: context,
      color: '\x1B[32m', // Green
    );
  }

  @override
  Future<void> warning(String message, [Map<String, dynamic>? context]) async {
    _log(
      message,
      level: 'WARN',
      context: context,
      color: '\x1B[33m', // Yellow
    );
  }

  @override
  Future<void> error(String message,
      [dynamic error, StackTrace? stackTrace]) async {
    _log(
      message,
      level: 'ERROR',
      context: error != null ? {'error': error.toString()} : null,
      stackTrace: stackTrace,
      color: '\x1B[31m', // Red
    );
  }

  void _log(
    String message, {
    required String level,
    Map<String, dynamic>? context,
    StackTrace? stackTrace,
    required String color,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final contextStr = context != null ? ' | context: $context' : '';
    final stackTraceStr = stackTrace != null ? '\n$stackTrace' : '';

    final formattedMessage =
        '$color[$prefix][$level][$timestamp] $message$contextStr$stackTraceStr\x1B[0m';

    developer.log(
      formattedMessage,
      time: DateTime.now(),
      level: _getLevelNumber(level),
      error: context?['error'],
      stackTrace: stackTrace,
    );
  }

  int _getLevelNumber(String level) {
    switch (level) {
      case 'DEBUG':
        return 500;
      case 'INFO':
        return 800;
      case 'WARN':
        return 900;
      case 'ERROR':
        return 1000;
      default:
        return 0;
    }
  }
}
