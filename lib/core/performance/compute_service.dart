import 'dart:isolate';
import 'package:flutter/foundation.dart';
import '../logging/logger_service.dart';

class ComputeService {
  final LoggerService _logger;
  final Map<String, Isolate> _activeIsolates = {};

  ComputeService({
    required LoggerService logger,
  }) : _logger = logger;

  Future<T> executeTask<T, P>({
    required String taskId,
    required P params,
    required ComputeCallback<T, P> computation,
  }) async {
    try {
      final result = await compute(computation, params);
      _logger.info('Task completed successfully: $taskId');
      return result;
    } catch (e) {
      _logger.error('Task failed: $taskId', e);
      rethrow;
    }
  }

  Future<void> startLongRunningTask({
    required String taskId,
    required Function(SendPort) task,
    required Function(dynamic) onMessage,
  }) async {
    if (_activeIsolates.containsKey(taskId)) {
      _logger.warning('Task already running: $taskId');
      return;
    }

    try {
      final receivePort = ReceivePort();
      final isolate = await Isolate.spawn(task, receivePort.sendPort);

      _activeIsolates[taskId] = isolate;

      receivePort.listen(
        onMessage,
        onError: (e) {
          _logger.error('Error in long running task: $taskId', e);
          _stopTask(taskId);
        },
        onDone: () {
          _logger.info('Long running task completed: $taskId');
          _stopTask(taskId);
        },
      );
    } catch (e) {
      _logger.error('Failed to start task: $taskId', e);
      rethrow;
    }
  }

  void _stopTask(String taskId) {
    final isolate = _activeIsolates.remove(taskId);
    isolate?.kill();
  }

  void dispose() {
    for (final taskId in _activeIsolates.keys) {
      _stopTask(taskId);
    }
    _activeIsolates.clear();
  }
}
