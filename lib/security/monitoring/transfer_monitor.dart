import 'dart:async';

import 'package:injectable/injectable.dart';
import '../../core/interfaces/transfer_monitor_interface.dart';
import '../../core/interfaces/logger_service_interface.dart';

@singleton
class TransferMonitor implements ITransferMonitor {
  final ILoggerService _logger;
  final _eventController = StreamController<TransferEvent>.broadcast();
  final List<TransferEvent> _events = [];
  bool _isInitialized = false;

  TransferMonitor(this._logger);

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      _logger.warning('TransferMonitor already initialized');
      return;
    }

    _logger.info('Initializing TransferMonitor');
    _isInitialized = true;
    _logger.info('TransferMonitor initialized');
  }

  @override
  Future<void> recordAttempt(int attempt) async {
    if (!_isInitialized) {
      _logger.error('TransferMonitor not initialized');
      return;
    }

    final event = TransferEvent(
      type: TransferEventType.attemptStarted,
      data: {'attempt': attempt},
    );
    _events.add(event);
    _eventController.add(event);
    _logger.info('Recorded transfer attempt: $attempt');
  }

  @override
  Future<void> recordFailure(int attempt, Object error) async {
    if (!_isInitialized) {
      _logger.error('TransferMonitor not initialized');
      return;
    }

    final event = TransferEvent(
      type: TransferEventType.attemptFailed,
      data: {
        'attempt': attempt,
        'error': error.toString(),
      },
    );
    _events.add(event);
    _eventController.add(event);
    _logger.warning('Recorded transfer failure: $error');
  }

  @override
  Future<bool> shouldSwitchToQr() async {
    if (!_isInitialized) {
      _logger.error('TransferMonitor not initialized');
      return false;
    }

    final failedAttempts =
        _events.where((e) => e.type == TransferEventType.attemptFailed).length;

    if (failedAttempts >= 3) {
      final event = TransferEvent(
        type: TransferEventType.switchingMethod,
        data: {'failedAttempts': failedAttempts},
      );
      _events.add(event);
      _eventController.add(event);
      _logger.info(
          'Switching to QR transfer after $failedAttempts failed attempts');
      return true;
    }

    return false;
  }

  @override
  Future<TransferStats> getStats() async {
    if (!_isInitialized) {
      _logger.error('TransferMonitor not initialized');
      return TransferStats(
        totalAttempts: 0,
        failedAttempts: 0,
        averageAttemptDuration: Duration.zero,
        lastAttemptTime: DateTime.now(),
        isStable: false,
      );
    }

    final totalAttempts =
        _events.where((e) => e.type == TransferEventType.attemptStarted).length;
    final failedAttempts =
        _events.where((e) => e.type == TransferEventType.attemptFailed).length;

    return TransferStats(
      totalAttempts: totalAttempts,
      failedAttempts: failedAttempts,
      averageAttemptDuration: Duration(seconds: 1), // Simulirano
      lastAttemptTime:
          _events.isNotEmpty ? _events.last.timestamp : DateTime.now(),
      isStable: failedAttempts < 3,
    );
  }

  @override
  Stream<TransferEvent> get transferEvents => _eventController.stream;

  @override
  Future<void> dispose() async {
    await _eventController.close();
    _events.clear();
    _isInitialized = false;
    _logger.info('TransferMonitor disposed');
  }
}
