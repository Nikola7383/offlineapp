import '../interfaces/base_service.dart';
import '../interfaces/logger.dart';
import '../errors/app_error.dart';

abstract class BaseServiceImpl implements BaseService {
  final Logger _logger;
  bool _isInitialized = false;

  BaseServiceImpl(this._logger);

  @override
  bool get isInitialized => _isInitialized;

  @override
  String get serviceId;

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      await _logger.warning('$serviceId already initialized');
      return;
    }

    try {
      await _logger.info('Initializing $serviceId');
      await onInitialize();
      _isInitialized = true;
      await _logger.info('$serviceId initialized successfully');
    } catch (e, stackTrace) {
      await _logger.error('Failed to initialize $serviceId', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    if (!_isInitialized) {
      await _logger.warning('$serviceId already disposed');
      return;
    }

    try {
      await _logger.info('Disposing $serviceId');
      await onDispose();
      _isInitialized = false;
      await _logger.info('$serviceId disposed successfully');
    } catch (e, stackTrace) {
      await _logger.error('Failed to dispose $serviceId', e, stackTrace);
      rethrow;
    }
  }

  /// Template method za inicijalizaciju specifičnu za servis
  Future<void> onInitialize();

  /// Template method za dispose specifičan za servis
  Future<void> onDispose();

  /// Helper metoda za proveru inicijalizacije
  void checkInitialized() {
    if (!_isInitialized) {
      throw StateError('$serviceId not initialized');
    }
  }

  /// Helper za wrapping operacija sa error handling-om
  Future<T> wrapOperation<T>(
      String operation, Future<T> Function() action) async {
    checkInitialized();

    try {
      await _logger.debug('$serviceId: Starting $operation');
      final result = await action();
      await _logger.debug('$serviceId: Completed $operation');
      return result;
    } catch (e, stackTrace) {
      await _logger.error('$serviceId: Failed $operation', e, stackTrace);
      throw AppError('$operation failed', e, stackTrace);
    }
  }
}
