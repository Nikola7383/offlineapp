import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';
import '../interfaces/logger_service_interface.dart';

/// Implementacija logger servisa sa podrškom za file logging
@singleton
class LoggerService implements ILoggerService {
  static const String _logFileName = 'app.log';
  static const int _maxLogSizeBytes = 5 * 1024 * 1024; // 5MB

  final List<String> _memoryLogs = [];
  final Lock _fileLock = Lock();
  late final File _logFile;
  bool _isInitialized = false;

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    if (isInitialized) return;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      _logFile = File('${appDir.path}${Platform.pathSeparator}$_logFileName');
      await _createLogFileIfNeeded();
      _isInitialized = true;
      await info('Logger service initialized');
    } catch (e, stackTrace) {
      print('Failed to initialize logger: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> _createLogFileIfNeeded() async {
    if (!await _logFile.exists()) {
      await _logFile.create(recursive: true);
    }
  }

  @override
  Future<void> info(String message) async {
    await _log('INFO', message);
  }

  @override
  Future<void> warning(String message) async {
    await _log('WARNING', message);
  }

  @override
  Future<void> error(String message,
      [dynamic error, StackTrace? stackTrace]) async {
    final errorMessage = error != null ? ': $error' : '';
    final stackMessage = stackTrace != null ? '\n$stackTrace' : '';
    await _log('ERROR', '$message$errorMessage$stackMessage');
  }

  Future<void> _log(String level, String message) async {
    if (!isInitialized) {
      print('Logger not initialized: [$level] $message');
      return;
    }

    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] $level: $message';

    // Dodaj u memoriju
    _memoryLogs.add(logMessage);

    // Sačuvaj u fajl
    await _fileLock.synchronized(() async {
      try {
        await _checkRotation();
        await _logFile.writeAsString('$logMessage\n', mode: FileMode.append);
      } catch (e, stackTrace) {
        print('Failed to write to log file: $e\n$stackTrace');
      }
    });
  }

  Future<void> _checkRotation() async {
    try {
      final stats = await _logFile.stat();
      if (stats.size > _maxLogSizeBytes) {
        final backupFile = File('${_logFile.path}.1');
        if (await backupFile.exists()) {
          await backupFile.delete();
        }
        await _logFile.rename(_logFile.path + '.1');
        await _logFile.create();
      }
    } catch (e, stackTrace) {
      print('Failed to rotate log file: $e\n$stackTrace');
    }
  }

  /// Vraća sve logove iz memorije
  @override
  List<String> getMemoryLogs() {
    return List.unmodifiable(_memoryLogs);
  }

  /// Vraća sve logove iz fajla
  @override
  Future<List<String>> getFileLogs() async {
    if (!isInitialized) return [];

    try {
      final contents = await _logFile.readAsString();
      return contents.split('\n').where((line) => line.isNotEmpty).toList();
    } catch (e) {
      error('Failed to read log file', e);
      return [];
    }
  }

  @override
  Future<void> dispose() async {
    if (!isInitialized) return;

    _memoryLogs.clear();
    _isInitialized = false;
    await info('Logger service disposed');
  }
}
