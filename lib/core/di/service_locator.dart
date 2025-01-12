import 'package:injectable/injectable.dart';
import '../interfaces/base_service.dart';
import '../interfaces/logger_service.dart';

/// Interfejs za servis lokator
abstract class IServiceLocator {
  /// Inicijalizuje servis lokator
  Future<void> initialize();

  /// Oslobađa resurse
  Future<void> dispose();

  /// Registruje servis
  void register<T extends IService>(T instance);

  /// Vraća registrovani servis
  T get<T extends IService>();

  /// Proverava da li je servis registrovan
  bool isRegistered<T extends IService>();
}

@LazySingleton(as: IServiceLocator)
class ServiceLocator implements IServiceLocator {
  final ILoggerService _logger;
  final Map<Type, IService> _services = {};
  bool _isInitialized = false;

  ServiceLocator(this._logger);

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Registruj osnovne servise
      register<ILoggerService>(_logger);

      // Inicijalizuj sve servise
      for (final service in _services.values) {
        await service.initialize();
      }

      _isInitialized = true;
      _logger.info('ServiceLocator initialized successfully');
    } catch (e, stackTrace) {
      _logger.error('Failed to initialize ServiceLocator', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    try {
      for (final service in _services.values) {
        await service.dispose();
      }
      _services.clear();
      _isInitialized = false;
      _logger.info('ServiceLocator disposed successfully');
    } catch (e, stackTrace) {
      _logger.error('Failed to dispose ServiceLocator', e, stackTrace);
      rethrow;
    }
  }

  @override
  void register<T extends IService>(T instance) {
    _services[T] = instance;
    _logger.debug('Registered service: ${T.toString()}');
  }

  @override
  T get<T extends IService>() {
    final service = _services[T];
    if (service == null) {
      final error = Exception('Service not found: ${T.toString()}');
      _logger.error('Failed to get service', error);
      throw error;
    }
    return service as T;
  }

  @override
  bool isRegistered<T extends IService>() {
    return _services.containsKey(T);
  }
}
