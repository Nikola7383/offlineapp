import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  late Logger _logger;
  File? _logFile;

  factory LoggerService() {
    return _instance;
  }

  LoggerService._internal() {
    _initLogger();
  }

  Future<void> _initLogger() async {
    final directory = await getApplicationDocumentsDirectory();
    _logFile = File('${directory.path}/logs/glasnik.log');

    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
      output: MultiOutput([
        ConsoleOutput(),
        FileOutput(file: _logFile!),
      ]),
    );
  }

  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error, stackTrace);
  }

  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error, stackTrace);
  }

  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error, stackTrace);
  }

  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error, stackTrace);
  }

  Future<String> getLogs() async {
    if (_logFile == null || !await _logFile!.exists()) {
      return 'No logs available';
    }
    return await _logFile!.readAsString();
  }
}
