import 'package:injectable/injectable.dart';
import '../../core/interfaces/base_service.dart';
import '../../core/interfaces/logger_service_interface.dart';

@singleton
class MinimalOperation implements IService {
  final ILoggerService _logger;
  bool _isInitialized = false;
  bool _isMinimalModeActive = false;
  final Set<String> _activeServices = {};

  MinimalOperation(this._logger);

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    await _logger.info('Initializing MinimalOperation');
    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    if (_isMinimalModeActive) {
      await _logger.warning('Disposing while minimal mode is active');
      await deactivate();
    }
    await _logger.info('Disposing MinimalOperation');
    _isInitialized = false;
  }

  Future<void> activate() async {
    if (!_isInitialized) {
      await _logger
          .error('Attempted to activate minimal mode before initialization');
      throw StateError('MinimalOperation not initialized');
    }
    if (_isMinimalModeActive) {
      await _logger.warning('Minimal mode already active');
      return;
    }
    await _logger.warning('Activating minimal operation mode');
    _isMinimalModeActive = true;
    await configureMinimalServices();
    // TODO: Implementirati aktivaciju minimalnog režima rada
    throw UnimplementedError();
  }

  Future<void> deactivate() async {
    if (!_isInitialized) {
      await _logger
          .error('Attempted to deactivate minimal mode before initialization');
      throw StateError('MinimalOperation not initialized');
    }
    if (!_isMinimalModeActive) {
      await _logger.warning('Minimal mode not active');
      return;
    }
    await _logger.info('Deactivating minimal operation mode');
    _isMinimalModeActive = false;
    _activeServices.clear();
    // TODO: Implementirati deaktivaciju minimalnog režima rada
    throw UnimplementedError();
  }

  Future<bool> isActive() async {
    if (!_isInitialized) {
      await _logger.error(
          'Attempted to check minimal mode status before initialization');
      throw StateError('MinimalOperation not initialized');
    }
    return _isMinimalModeActive;
  }

  Future<void> configureMinimalServices() async {
    if (!_isInitialized) {
      await _logger.error(
          'Attempted to configure minimal services before initialization');
      throw StateError('MinimalOperation not initialized');
    }
    if (!_isMinimalModeActive) {
      await _logger
          .error('Cannot configure services when minimal mode is not active');
      throw StateError('Minimal mode not active');
    }
    await _logger.info('Configuring minimal services');
    _activeServices.clear();
    // TODO: Implementirati konfiguraciju minimalnih servisa
    throw UnimplementedError();
  }

  Future<List<String>> getActiveServices() async {
    if (!_isInitialized) {
      await _logger
          .error('Attempted to get active services before initialization');
      throw StateError('MinimalOperation not initialized');
    }
    await _logger.info('Retrieving list of active services');
    return _activeServices.toList();
  }
}
