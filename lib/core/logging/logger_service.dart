import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../interfaces/base_service.dart';

/// Servis za logovanje
@LazySingleton()
class LoggerService implements IService {
  final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  @override
  Future<void> initialize() async {
    // Nema potrebe za inicijalizacijom
  }

  @override
  Future<void> dispose() async {
    // Nema potrebe za čišćenjem resursa
  }

  /// Loguje debug poruku
  void debug(String message, [dynamic error]) {
    _logger.d(message);
  }

  /// Loguje info poruku
  void info(String message, [dynamic error]) {
    _logger.i(message);
  }

  /// Loguje warning poruku
  void warning(String message, [dynamic error]) {
    _logger.w(message);
  }

  /// Loguje error poruku
  void error(String message, [dynamic error]) {
    _logger.e(message);
  }

  /// Loguje fatal error poruku
  void fatal(String message, [dynamic error]) {
    _logger.e('FATAL: $message');
  }
}
