import 'package:injectable/injectable.dart';
import 'logger_service_interface.dart';

/// Osnovni interfejs za sve servise u aplikaciji
abstract class IService {
  /// Inicijalizuje servis
  Future<void> initialize();

  /// Proverava da li je servis inicijalizovan
  bool get isInitialized;

  /// Oslobađa resurse koje servis koristi
  Future<void> dispose();
}

/// Interfejs za servise koji zahtevaju čišćenje resursa
abstract class Disposable {
  /// Oslobađa resurse koje servis koristi
  Future<void> dispose();
}

/// Bazna klasa za sve servise koji koriste dependency injection
abstract class InjectableService implements IService {
  final ILoggerService _logger;
  bool _isInitialized = false;

  InjectableService(this._logger);

  @override
  bool get isInitialized => _isInitialized;

  /// Loguje informativnu poruku
  void logInfo(String message) {
    _logger.info(message);
  }

  /// Loguje upozorenje
  void logWarning(String message) {
    _logger.warning(message);
  }

  /// Loguje grešku
  void logError(String message) {
    _logger.error(message);
  }
}
