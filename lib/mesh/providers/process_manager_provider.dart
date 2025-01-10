import 'package:riverpod/riverpod.dart';
import '../models/process_info.dart';
import '../process/process_manager.dart';

/// Provider za menadžer procesa
final processManagerProvider = Provider<ProcessManager>((ref) {
  final manager = ProcessManager();
  ref.onDispose(() => manager.dispose());
  return manager;
});

/// Provider za aktivne procese
final activeProcessesProvider =
    StreamProvider.family<List<ProcessInfo>, String>((ref, nodeId) async* {
  final manager = ref.watch(processManagerProvider);
  final processes = await manager.getActiveProcesses(nodeId);
  yield processes;

  await for (final _ in manager.processStateChanges) {
    final updatedProcesses = await manager.getActiveProcesses(nodeId);
    yield updatedProcesses;
  }
});

/// Provider za pokretanje procesa
final processStarterProvider = Provider<ProcessStarter>((ref) {
  final manager = ref.watch(processManagerProvider);
  return ProcessStarter(manager: manager);
});

/// Klasa za pokretanje procesa
class ProcessStarter {
  final ProcessManager manager;

  ProcessStarter({required this.manager});

  /// Pokreće Network Monitor proces
  Future<void> startNetworkMonitor(String nodeId) async {
    await manager.startProcess(
      nodeId,
      'network_monitor',
      ProcessPriority.high,
    );
  }

  /// Pokreće Security Scanner proces
  Future<void> startSecurityScanner(String nodeId) async {
    await manager.startProcess(
      nodeId,
      'security_scanner',
      ProcessPriority.high,
    );
  }
}
