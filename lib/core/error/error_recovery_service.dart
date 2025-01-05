import 'dart:async';
import '../logging/logger_service.dart';
import '../config/app_config.dart';
import '../storage/database_service.dart';
import '../mesh/mesh_network.dart';

class ErrorRecoveryService {
  final LoggerService _logger;
  final DatabaseService _storage;
  final MeshNetwork _meshNetwork;
  final _pendingOperations = <_PendingOperation>[];
  Timer? _recoveryTimer;

  ErrorRecoveryService({
    required LoggerService logger,
    required DatabaseService storage,
    required MeshNetwork meshNetwork,
  })  : _logger = logger,
        _storage = storage,
        _meshNetwork = meshNetwork {
    _startRecoveryTimer();
  }

  void _startRecoveryTimer() {
    _recoveryTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _attemptRecovery(),
    );
  }

  Future<void> registerFailedOperation<T>({
    required String type,
    required T data,
    required Future<void> Function() operation,
  }) async {
    final pendingOp = _PendingOperation<T>(
      type: type,
      data: data,
      operation: operation,
      attempts: 0,
      lastAttempt: DateTime.now(),
    );

    _pendingOperations.add(pendingOp);
    _logger.warning('Registered failed operation: $type');

    await _attemptRecovery();
  }

  Future<void> _attemptRecovery() async {
    if (_pendingOperations.isEmpty) return;

    for (var i = _pendingOperations.length - 1; i >= 0; i--) {
      final op = _pendingOperations[i];

      if (op.attempts >= AppConfig.maxRetries) {
        _logger.error('Operation failed permanently: ${op.type}');
        _pendingOperations.removeAt(i);
        continue;
      }

      if (_shouldRetry(op)) {
        try {
          await op.operation();
          _logger.info('Recovered operation: ${op.type}');
          _pendingOperations.removeAt(i);
        } catch (e) {
          op.attempts++;
          op.lastAttempt = DateTime.now();
          _logger.warning(
            'Recovery attempt ${op.attempts} failed for ${op.type}',
            e,
          );
        }
      }
    }
  }

  bool _shouldRetry(_PendingOperation op) {
    final timeSinceLastAttempt = DateTime.now().difference(op.lastAttempt);
    final backoffDuration = Duration(
      seconds: pow(2, op.attempts).toInt(),
    );
    return timeSinceLastAttempt >= backoffDuration;
  }

  void dispose() {
    _recoveryTimer?.cancel();
    _pendingOperations.clear();
  }
}

class _PendingOperation<T> {
  final String type;
  final T data;
  final Future<void> Function() operation;
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
