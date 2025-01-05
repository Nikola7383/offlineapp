import '../interfaces/base_service.dart';
import '../interfaces/logger_service.dart';
import '../models/service_error.dart';

/// Osnovna implementacija servisa sa error handling-om
abstract class BaseService implements IService {
  final ILoggerService _logger;
  bool _isInitialized = false;

  BaseService(this._logger);

  @override
  bool get isInitialized => _isInitialized;

  /// Ime servisa za logging
  String get serviceName;

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      await _logger.warning('$serviceName already initialized');
      return;
    }

    try {
      await _logger.info('Initializing $serviceName');
      await onInitialize();
      _isInitialized = true;
      await _logger.info('$serviceName initialized successfully');
    } catch (e, stackTrace) {
      await _logger.error('Failed to initialize $serviceName', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    if (!_isInitialized) {
      await _logger.warning('$serviceName already disposed');
      return;
    }

    try {
      await _logger.info('Disposing $serviceName');
      await onDispose();
      _isInitialized = false;
      await _logger.info('$serviceName disposed successfully');
    } catch (e, stackTrace) {
      await _logger.error('Failed to dispose $serviceName', e, stackTrace);
      rethrow;
    }
  }

  /// Template metoda za inicijalizaciju
  Future<void> onInitialize();

  /// Template metoda za dispose
  Future<void> onDispose();

  /// Proverava da li je servis inicijalizovan
  void checkInitialized() {
    if (!_isInitialized) {
      throw ServiceError('$serviceName not initialized');
    }
  }

  /// Wrapper za operacije sa error handling-om
  Future<T> wrapOperation<T>(
    String operation,
    Future<T> Function() action,
  ) async {
    checkInitialized();

    try {
      await _logger.debug('$serviceName: Starting $operation');
      final result = await action();
      await _logger.debug('$serviceName: Completed $operation');
      return result;
    } catch (e, stackTrace) {
      await _logger.error('$serviceName: Failed $operation', e, stackTrace);
      throw ServiceError('$operation failed', e, stackTrace);
    }
  }
}
