import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/mesh/models/process_info.dart';
import 'package:secure_event_app/mesh/process/process_starter.dart';
import 'package:secure_event_app/mesh/providers/process_starter_provider.dart';

void main() {
  group('ProcessStarterProvider', () {
    late ProviderContainer container;
    late String nodeId;

    setUp(() {
      container = ProviderContainer();
      nodeId = 'test-node';
    });

    tearDown(() {
      container.dispose();
    });

    test('should provide ProcessStarter instance', () {
      final starter = container.read(processStarterProvider);
      expect(starter, isA<ProcessStarter>());
    });

    test('should start network monitor process', () async {
      final starter = container.read(processStarterProvider);
      final process = await starter.startNetworkMonitor(nodeId);

      expect(process.name, equals('network_monitor'));
      expect(process.status, equals(ProcessStatus.running));
      expect(process.priority, equals(ProcessPriority.normal));
    });

    test('should start security scanner process', () async {
      final starter = container.read(processStarterProvider);
      final process = await starter.startSecurityScanner(nodeId);

      expect(process.name, equals('security_scanner'));
      expect(process.status, equals(ProcessStatus.running));
      expect(process.priority, equals(ProcessPriority.normal));
    });

    test('should start predictive threat analyzer process', () async {
      final starter = container.read(processStarterProvider);
      final process = await starter.startPredictiveThreatAnalyzer(nodeId);

      expect(process.name, equals('predictive_threat_analyzer'));
      expect(process.status, equals(ProcessStatus.running));
      expect(process.priority, equals(ProcessPriority.normal));
    });

    test('should start process with custom priority', () async {
      final starter = container.read(processStarterProvider);
      final process = await starter.startNetworkMonitor(
        nodeId,
        priority: ProcessPriority.high,
      );

      expect(process.priority, equals(ProcessPriority.high));
    });

    test('should start process with custom config', () async {
      final starter = container.read(processStarterProvider);
      final config = {
        'customSetting': 'value',
      };

      final process = await starter.startNetworkMonitor(
        nodeId,
        config: config,
      );

      expect(process.status, equals(ProcessStatus.running));
    });

    test('should throw when starting process with invalid node id', () async {
      final starter = container.read(processStarterProvider);

      expect(
        () => starter.startNetworkMonitor(''),
        throwsArgumentError,
      );
    });

    test('should throw when starting process with invalid priority', () async {
      final starter = container.read(processStarterProvider);

      expect(
        () => starter.startNetworkMonitor(
          nodeId,
          priority: ProcessPriority.unknown,
        ),
        throwsArgumentError,
      );
    });
  });
}
