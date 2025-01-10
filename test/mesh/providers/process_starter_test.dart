import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/mesh/models/process_info.dart';
import 'package:secure_event_app/mesh/process/process_manager.dart';
import 'package:secure_event_app/mesh/providers/process_manager_provider.dart';

void main() {
  group('ProcessStarter', () {
    late ProcessManager manager;
    late ProcessStarter starter;
    late String nodeId;

    setUp(() {
      manager = ProcessManager();
      starter = ProcessStarter(manager: manager);
      nodeId = 'test-node';
    });

    tearDown(() {
      manager.dispose();
    });

    test('should start network monitor', () async {
      await starter.startNetworkMonitor(nodeId);

      final processes = await manager.getActiveProcesses(nodeId);
      expect(processes.length, 1);
      expect(processes.first.name, 'network_monitor');
      expect(processes.first.status, ProcessStatus.running);
      expect(processes.first.priority, ProcessPriority.high);
    });

    test('should start security scanner', () async {
      await starter.startSecurityScanner(nodeId);

      final processes = await manager.getActiveProcesses(nodeId);
      expect(processes.length, 1);
      expect(processes.first.name, 'security_scanner');
      expect(processes.first.status, ProcessStatus.running);
      expect(processes.first.priority, ProcessPriority.high);
    });

    test('should throw when manager is disposed', () async {
      manager.dispose();

      expect(
        () => starter.startNetworkMonitor(nodeId),
        throwsStateError,
      );

      expect(
        () => starter.startSecurityScanner(nodeId),
        throwsStateError,
      );
    });
  });
}
