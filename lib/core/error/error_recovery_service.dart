import 'dart:async';
import 'package:injectable/injectable.dart';
import '../interfaces/logger_service_interface.dart';
import '../interfaces/database_service_interface.dart';
import '../interfaces/mesh_network_interface.dart';
import '../interfaces/base_service.dart';
import '../config/recovery_config.dart';

typedef RecoveryOperation = Future<void> Function();

class _PendingOperation<T> {
  final String type;
  final T data;
  final RecoveryOperation operation;
  int attempts;
  DateTime lastAttempt;

  _PendingOperation({
    required this.type,
    required this.data,
    required this.operation,
    required this.attempts,
    required this.lastAttempt,
  });
}

@singleton
class ErrorRecoveryService implements IService, Disposable {
  final ILoggerService _logger;
  final IDatabaseService _storage;
  final IMeshNetwork _meshNetwork;
  final _pendingOperations = <_PendingOperation>[];
  Timer? _recoveryTimer;
  bool _isInitialized = false;

  ErrorRecoveryService(
    this._logger,
    this._storage,
    this._meshNetwork,
  );

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    await _logger.info('Initializing ErrorRecoveryService');
    _startRecoveryTimer();
    _isInitialized = true;
  }

  void _startRecoveryTimer() {
    _recoveryTimer = Timer.periodic(
      RecoveryConfig.recoveryInterval,
      (_) => _attemptRecovery(),
    );
  }

  Future<void> registerFailedOperation<T>({
    required String type,
    required T data,
    required RecoveryOperation operation,
  }) async {
    if (!_isInitialized) {
      await _logger
          .error('Attempted to register operation before initialization');
      throw StateError('ErrorRecoveryService not initialized');
    }

    final pendingOp = _PendingOperation<T>(
      type: type,
      data: data,
      operation: operation,
      attempts: 0,
      lastAttempt: DateTime.now(),
    );

    _pendingOperations.add(pendingOp);
    await _logger.warning('Registered failed operation: $type');

    await _attemptRecovery();
  }

  Future<void> _attemptRecovery() async {
    if (!_isInitialized) return;
    if (_pendingOperations.isEmpty) return;

    for (var i = _pendingOperations.length - 1; i >= 0; i--) {
      final op = _pendingOperations[i];

      if (op.attempts >= RecoveryConfig.maxRetries) {
        await _logger.error('Operation failed permanently: ${op.type}');
        _pendingOperations.removeAt(i);
        continue;
      }

      if (_shouldRetry(op)) {
        try {
          await op.operation();
          await _logger.info('Recovered operation: ${op.type}');
          _pendingOperations.removeAt(i);
        } catch (e) {
          op.attempts++;
          op.lastAttempt = DateTime.now();
          await _logger.warning(
            'Recovery attempt ${op.attempts} failed for ${op.type}: $e',
          );
        }
      }
    }
  }

  bool _shouldRetry(_PendingOperation op) {
    final timeSinceLastAttempt = DateTime.now().difference(op.lastAttempt);
    final backoffDuration = Duration(
      seconds: RecoveryConfig.backoffMultiplier * op.attempts,
    );
    return timeSinceLastAttempt >= backoffDuration;
  }

  @override
  Future<void> dispose() async {
    if (!_isInitialized) return;

    await _logger.info('Disposing ErrorRecoveryService');
    _recoveryTimer?.cancel();
    _pendingOperations.clear();
    _isInitialized = false;
  }
}
