import 'package:injectable/injectable.dart';
import '../../core/interfaces/base_service.dart';
import '../../core/interfaces/logger_service_interface.dart';

@singleton
class PowerManager implements IService {
  final ILoggerService _logger;
  bool _isInitialized = false;
  bool _isLowPowerMode = false;

  PowerManager(this._logger);

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    await _logger.info('Initializing PowerManager');
    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    if (_isLowPowerMode) {
      await exitLowPowerMode();
    }
    await _logger.info('Disposing PowerManager');
    _isInitialized = false;
  }

  Future<void> optimizePowerUsage() async {
    if (!_isInitialized) {
      await _logger
          .error('Attempted to optimize power usage before initialization');
      throw StateError('PowerManager not initialized');
    }
    await _logger.info('Starting power usage optimization');
    // TODO: Implementirati optimizaciju potrošnje energije
    throw UnimplementedError();
  }

  Future<double> getCurrentPowerUsage() async {
    if (!_isInitialized) {
      await _logger
          .error('Attempted to get current power usage before initialization');
      throw StateError('PowerManager not initialized');
    }
    // TODO: Implementirati dobavljanje trenutne potrošnje energije
    throw UnimplementedError();
  }

  Future<void> enterLowPowerMode() async {
    if (!_isInitialized) {
      await _logger
          .error('Attempted to enter low power mode before initialization');
      throw StateError('PowerManager not initialized');
    }
    if (_isLowPowerMode) {
      await _logger.warning('Already in low power mode');
      return;
    }
    await _logger.info('Entering low power mode');
    _isLowPowerMode = true;
    // TODO: Implementirati ulazak u režim niske potrošnje
    throw UnimplementedError();
  }

  Future<void> exitLowPowerMode() async {
    if (!_isInitialized) {
      await _logger
          .error('Attempted to exit low power mode before initialization');
      throw StateError('PowerManager not initialized');
    }
    if (!_isLowPowerMode) {
      await _logger.warning('Not in low power mode');
      return;
    }
    await _logger.info('Exiting low power mode');
    _isLowPowerMode = false;
    // TODO: Implementirati izlazak iz režima niske potrošnje
    throw UnimplementedError();
  }

  Future<bool> isLowPowerModeActive() async {
    if (!_isInitialized) {
      await _logger
          .error('Attempted to check low power mode before initialization');
      throw StateError('PowerManager not initialized');
    }
    return _isLowPowerMode;
  }
}
