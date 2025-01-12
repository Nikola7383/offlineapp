import 'base_service.dart';

/// Interfejs za logovanje
abstract class ILoggerService implements IService {
  /// Inicijalizuje logger servis
  Future<void> initialize();

  /// Loguje informativnu poruku
  Future<void> info(String message);

  /// Loguje upozorenje
  Future<void> warning(String message);

  /// Loguje grešku
  Future<void> error(String message, [dynamic error, StackTrace? stackTrace]);

  /// Oslobađa resurse
  Future<void> dispose();

  /// Vraća sve logove iz memorije
  List<String> getMemoryLogs();

  /// Vraća sve logove iz fajla
  Future<List<String>> getFileLogs();
}

/// Nivoi logovanja
enum LogLevel { info, warning, error, critical }
