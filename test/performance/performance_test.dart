import 'package:test/test.dart';
import 'package:benchmark/benchmark.dart';

void main() {
  group('System Performance Tests', () {
    late PerformanceMetrics metrics;

    setUp(() {
      metrics = PerformanceMetrics();
    });

    test('Message Processing Speed', () async {
      final benchmark = Benchmark('Message Processing');

      // Test sa 1000 poruka
      await benchmark.measure(() async {
        for (var i = 0; i < 1000; i++) {
          await meshNetwork
              .sendMessage(Message(id: 'perf_$i', content: 'Test $i'));
        }
      });

      expect(benchmark.averageMs, lessThan(100)); // Max 100ms po poruci
    });

    test('Mesh Network Scaling', () async {
      final benchmark = Benchmark('Network Scaling');

      // Test sa 100 nodova
      await benchmark.measure(() async {
        for (var i = 0; i < 100; i++) {
          await meshNetwork.addNode('node_$i');
        }
      });

      expect(benchmark.totalMs, lessThan(5000)); // Max 5s za 100 nodova
    });

    test('Emergency Protocol Response Time', () async {
      final benchmark = Benchmark('Emergency Response');

      await benchmark.measure(() async {
        await emergencyService.activateEmergencyProtocol(
          activatorId: 'test_master',
          type: EmergencyType.systemCompromise,
        );
      });

      expect(benchmark.totalMs, lessThan(1000)); // Max 1s response time
    });
  });
}
