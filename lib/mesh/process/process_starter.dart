import 'package:secure_event_app/mesh/models/process_info.dart';
import 'package:secure_event_app/mesh/process/process_manager.dart';

class ProcessStarter {
  final ProcessManager _manager;

  ProcessStarter(this._manager);

  Future<ProcessInfo> startNetworkMonitor(
    String nodeId, {
    ProcessPriority priority = ProcessPriority.normal,
    Map<String, dynamic>? config,
  }) async {
    _validateNodeId(nodeId);
    _validatePriority(priority);

    return _manager.startProcess(
      nodeId,
      'network_monitor',
      priority,
      config: config,
    );
  }

  Future<ProcessInfo> startSecurityScanner(
    String nodeId, {
    ProcessPriority priority = ProcessPriority.normal,
    Map<String, dynamic>? config,
  }) async {
    _validateNodeId(nodeId);
    _validatePriority(priority);

    return _manager.startProcess(
      nodeId,
      'security_scanner',
      priority,
      config: config,
    );
  }

  Future<ProcessInfo> startPredictiveThreatAnalyzer(
    String nodeId, {
    ProcessPriority priority = ProcessPriority.normal,
    Map<String, dynamic>? config,
  }) async {
    _validateNodeId(nodeId);
    _validatePriority(priority);

    return _manager.startProcess(
      nodeId,
      'predictive_threat_analyzer',
      priority,
      config: config,
    );
  }

  void _validateNodeId(String nodeId) {
    if (nodeId.isEmpty) {
      throw ArgumentError('Node ID cannot be empty');
    }
  }

  void _validatePriority(ProcessPriority priority) {
    if (priority == ProcessPriority.unknown) {
      throw ArgumentError('Invalid process priority');
    }
  }
}
