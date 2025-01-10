import 'dart:async';

import 'package:secure_event_app/mesh/models/process_info.dart';
import 'package:secure_event_app/mesh/models/process_key.dart';
import 'package:secure_event_app/mesh/models/process_state_change.dart';
import 'package:secure_event_app/mesh/models/process_stats.dart';

class ProcessManager {
  final Map<ProcessKey, ProcessInfo> _processes = {};
  final StreamController<ProcessStateChange> _stateChangeController =
      StreamController.broadcast();
  final StreamController<Map<ProcessKey, ProcessStats>> _statsController =
      StreamController.broadcast();

  Stream<ProcessStateChange> get stateChanges => _stateChangeController.stream;
  Stream<Map<ProcessKey, ProcessStats>> get stats => _statsController.stream;

  Future<ProcessInfo> startProcess(
    String nodeId,
    String name,
    ProcessPriority priority, {
    Map<String, dynamic>? config,
  }) async {
    final processId = DateTime.now().millisecondsSinceEpoch.toString();
    final key = ProcessKey(nodeId: nodeId, processId: processId);

    final process = ProcessInfo(
      id: processId,
      name: name,
      status: ProcessStatus.running,
      priority: priority,
      startTime: DateTime.now(),
      lastUpdateTime: DateTime.now(),
    );

    _processes[key] = process;
    _notifyStateChange(key, ProcessStatus.unknown, ProcessStatus.running);

    return process;
  }

  Future<void> stopProcess(ProcessKey key) async {
    final process = _processes[key];
    if (process == null) return;

    final oldStatus = process.status;
    _processes[key] = process.copyWith(status: ProcessStatus.stopped);
    _notifyStateChange(key, oldStatus, ProcessStatus.stopped);

    _processes.remove(key);
  }

  Future<void> pauseProcess(ProcessKey key) async {
    final process = _processes[key];
    if (process == null) return;

    final oldStatus = process.status;
    _processes[key] = process.copyWith(status: ProcessStatus.paused);
    _notifyStateChange(key, oldStatus, ProcessStatus.paused);
  }

  Future<void> resumeProcess(ProcessKey key) async {
    final process = _processes[key];
    if (process == null) return;

    final oldStatus = process.status;
    _processes[key] = process.copyWith(status: ProcessStatus.running);
    _notifyStateChange(key, oldStatus, ProcessStatus.running);
  }

  Future<List<ProcessInfo>> getActiveProcesses(String nodeId) async {
    return _processes.entries
        .where((e) => e.key.nodeId == nodeId && e.value.isActive)
        .map((e) => e.value)
        .toList();
  }

  void _notifyStateChange(
      ProcessKey key, ProcessStatus oldStatus, ProcessStatus newStatus) {
    _stateChangeController.add(
      ProcessStateChange(
        key: key,
        oldStatus: oldStatus,
        newStatus: newStatus,
        timestamp: DateTime.now(),
      ),
    );
  }

  void dispose() {
    _stateChangeController.close();
    _statsController.close();
  }
}
