import 'dart:async';
import 'package:secure_event_app/mesh/process/process_executor.dart';

/// Mock implementacija ProcessExecutor-a za testiranje
class MockProcessExecutor implements ProcessExecutor {
  final Map<String, StreamController<Map<String, dynamic>>> _processStreams =
      {};
  final Map<String, bool> _isRunning = {};
  bool _throwError = false;

  /// Postavlja flag za simulaciju greške
  set throwError(bool value) => _throwError = value;

  @override
  Future<void> startProcess(
    String processId,
    Function processFunction,
    Map<String, dynamic>? config,
  ) async {
    if (_throwError) {
      throw Exception('Test error');
    }

    final streamController = StreamController<Map<String, dynamic>>.broadcast();
    _processStreams[processId] = streamController;
    _isRunning[processId] = true;

    // Simuliraj izvršavanje procesa
    Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isRunning[processId] == true) {
        streamController.add({
          'cpuUsage': 50.0,
          'memoryUsageMb': 1024,
          'threadCount': 4,
          'openFileCount': 10,
          'networkConnectionCount': 5,
        });
      }
    });
  }

  @override
  Future<void> stopProcess(String processId) async {
    if (_throwError) {
      throw Exception('Test error');
    }

    _isRunning[processId] = false;
    await _processStreams[processId]?.close();
    _processStreams.remove(processId);
  }

  @override
  Future<void> pauseProcess(String processId) async {
    if (_throwError) {
      throw Exception('Test error');
    }

    _isRunning[processId] = false;
  }

  @override
  Future<void> resumeProcess(String processId) async {
    if (_throwError) {
      throw Exception('Test error');
    }

    _isRunning[processId] = true;
  }

  @override
  Stream<Map<String, dynamic>>? getProcessStream(String processId) {
    return _processStreams[processId]?.stream;
  }

  @override
  void dispose() {
    for (final controller in _processStreams.values) {
      controller.close();
    }
    _processStreams.clear();
    _isRunning.clear();
  }

  /// Simulira grešku u procesu
  void simulateProcessError(String processId, String error) {
    _processStreams[processId]?.addError(error);
  }

  /// Simulira završetak procesa
  void simulateProcessCompletion(String processId) {
    _isRunning[processId] = false;
    _processStreams[processId]?.close();
    _processStreams.remove(processId);
  }
}
