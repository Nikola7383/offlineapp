import '../interfaces/logger_service_interface.dart';

/// Manager za upravljanje memorijom u security modulu
class SecurityMemoryManager {
  final ILoggerService _logger;
  final Map<String, Object> _objects = {};
  bool _isInitialized = false;

  SecurityMemoryManager(this._logger);

  /// Da li je manager inicijalizovan
  bool get isInitialized => _isInitialized;

  /// Inicijalizuje manager
  Future<void> initialize() async {
    _isInitialized = true;
    _logger.info('Security memory manager initialized');
  }

  /// Oslobađa resurse
  Future<void> dispose() async {
    _objects.clear();
    _isInitialized = false;
    _logger.info('Security memory manager disposed');
  }

  /// Registruje objekat
  Future<void> register(String key, Object value) async {
    _objects[key] = value;
    _logger.info('Registered object with key: $key');
  }

  /// Vraća objekat
  Future<Object?> get(String key) async {
    return _objects[key];
  }

  /// Uklanja objekat
  Future<void> unregister(String key) async {
    _objects.remove(key);
    _logger.info('Unregistered object with key: $key');
  }

  /// Vraća broj registrovanih objekata
  int get objectCount => _objects.length;

  /// Čisti sve objekte
  Future<void> clear() async {
    _objects.clear();
    _logger.info('Cleared all objects');
  }
}
