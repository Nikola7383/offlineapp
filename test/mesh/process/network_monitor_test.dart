import 'dart:isolate';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/mesh/process/network_monitor.dart';

abstract class NetworkStatsCollector {
  Future<List<NetworkInterfaceStats>> collectStats();
}

class MockNetworkStatsCollector implements NetworkStatsCollector {
  final List<NetworkInterfaceStats> mockStats;
  bool throwError = false;

  MockNetworkStatsCollector(this.mockStats);

  @override
  Future<List<NetworkInterfaceStats>> collectStats() async {
    if (throwError) {
      throw Exception('Test error');
    }
    return mockStats;
  }
}

void main() {
  group('NetworkMonitorConfig', () {
    test('should create instance with default values', () {
      final config = NetworkMonitorConfig();

      expect(config.sampleInterval, equals(const Duration(seconds: 1)));
      expect(config.interfacesToMonitor, equals(['all']));
      expect(config.maxSamplesPerReport, equals(60));
      expect(config.includePerProcessStats, isFalse);
    });

    test('should create instance with custom values', () {
      final config = NetworkMonitorConfig(
        sampleInterval: const Duration(seconds: 5),
        interfacesToMonitor: ['eth0', 'wlan0'],
        maxSamplesPerReport: 30,
        includePerProcessStats: true,
      );

      expect(config.sampleInterval, equals(const Duration(seconds: 5)));
      expect(config.interfacesToMonitor, equals(['eth0', 'wlan0']));
      expect(config.maxSamplesPerReport, equals(30));
      expect(config.includePerProcessStats, isTrue);
    });

    test('should convert to and from JSON', () {
      final original = NetworkMonitorConfig(
        sampleInterval: const Duration(seconds: 5),
        interfacesToMonitor: ['eth0', 'wlan0'],
        maxSamplesPerReport: 30,
        includePerProcessStats: true,
      );

      final json = original.toJson();
      final fromJson = NetworkMonitorConfig.fromJson(json);

      expect(fromJson.sampleInterval, equals(original.sampleInterval));
      expect(
          fromJson.interfacesToMonitor, equals(original.interfacesToMonitor));
      expect(
          fromJson.maxSamplesPerReport, equals(original.maxSamplesPerReport));
      expect(fromJson.includePerProcessStats,
          equals(original.includePerProcessStats));
    });
  });

  group('NetworkInterfaceStats', () {
    test('should create instance with required values', () {
      final now = DateTime.now();
      final stats = NetworkInterfaceStats(
        name: 'eth0',
        bytesReceived: 1000,
        bytesSent: 500,
        packetsReceived: 100,
        packetsSent: 50,
        errors: 2,
        drops: 1,
        timestamp: now,
      );

      expect(stats.name, equals('eth0'));
      expect(stats.bytesReceived, equals(1000));
      expect(stats.bytesSent, equals(500));
      expect(stats.packetsReceived, equals(100));
      expect(stats.packetsSent, equals(50));
      expect(stats.errors, equals(2));
      expect(stats.drops, equals(1));
      expect(stats.timestamp, equals(now));
    });

    test('should convert to JSON', () {
      final now = DateTime.now();
      final stats = NetworkInterfaceStats(
        name: 'eth0',
        bytesReceived: 1000,
        bytesSent: 500,
        packetsReceived: 100,
        packetsSent: 50,
        errors: 2,
        drops: 1,
        timestamp: now,
      );

      final json = stats.toJson();

      expect(json['name'], equals('eth0'));
      expect(json['bytesReceived'], equals(1000));
      expect(json['bytesSent'], equals(500));
      expect(json['packetsReceived'], equals(100));
      expect(json['packetsSent'], equals(50));
      expect(json['errors'], equals(2));
      expect(json['drops'], equals(1));
      expect(json['timestamp'], equals(now.toIso8601String()));
    });
  });

  group('NetworkMonitor', () {
    late ReceivePort receivePort;
    late NetworkMonitor monitor;
    late List<NetworkInterfaceStats> mockStats;

    setUp(() {
      receivePort = ReceivePort();
      final now = DateTime.now();

      mockStats = [
        NetworkInterfaceStats(
          name: 'eth0',
          bytesReceived: 1000,
          bytesSent: 500,
          packetsReceived: 100,
          packetsSent: 50,
          errors: 2,
          drops: 1,
          timestamp: now,
        ),
        NetworkInterfaceStats(
          name: 'wlan0',
          bytesReceived: 2000,
          bytesSent: 1000,
          packetsReceived: 200,
          packetsSent: 100,
          errors: 1,
          drops: 0,
          timestamp: now,
        ),
      ];

      monitor = NetworkMonitor(
        receivePort.sendPort,
        NetworkMonitorConfig().toJson(),
        statsCollector: MockNetworkStatsCollector(mockStats),
      );
    });

    tearDown(() {
      monitor.stop();
      receivePort.close();
    });

    test('should start and stop monitoring', () async {
      expect(monitor.isRunning, isFalse);
      expect(monitor.sampleTimer, isNull);

      monitor.start();
      expect(monitor.isRunning, isTrue);
      expect(monitor.sampleTimer, isNotNull);

      monitor.stop();
      expect(monitor.isRunning, isFalse);
      expect(monitor.sampleTimer, isNull);
    });

    test('should not start monitoring if already running', () {
      monitor.start();
      final timer = monitor.sampleTimer;

      monitor.start();
      expect(monitor.sampleTimer, equals(timer));
    });

    test('should collect network stats', () async {
      final stats = await monitor.collectNetworkStats();

      expect(stats, equals(mockStats));
      for (final stat in stats) {
        expect(stat, isA<NetworkInterfaceStats>());
        expect(stat.name, isNotEmpty);
        expect(stat.bytesReceived, isNonNegative);
        expect(stat.bytesSent, isNonNegative);
        expect(stat.packetsReceived, isNonNegative);
        expect(stat.packetsSent, isNonNegative);
        expect(stat.errors, isNonNegative);
        expect(stat.drops, isNonNegative);
        expect(stat.timestamp, isNotNull);
      }
    });

    test('should filter interfaces based on config', () async {
      final specificConfig = NetworkMonitorConfig(
        interfacesToMonitor: ['eth0'],
      );

      final specificMonitor = NetworkMonitor(
        receivePort.sendPort,
        specificConfig.toJson(),
        statsCollector: MockNetworkStatsCollector(mockStats),
      );

      final stats = await specificMonitor.collectNetworkStats();
      expect(stats.length, equals(1));
      expect(stats.first.name, equals('eth0'));
    });

    test('should send stats through port', () async {
      final messages = <Map<String, dynamic>>[];
      receivePort.listen((message) {
        if (message is Map<String, dynamic>) {
          messages.add(message);
        }
      });

      await monitor.collectAndSendStats();

      expect(messages.length, equals(1));
      expect(messages.first['type'], equals('stats'));
      expect(messages.first['data'], isA<List>());
      expect(messages.first['data'].length, equals(mockStats.length));
    });

    test('should handle errors gracefully', () async {
      final errorCollector = MockNetworkStatsCollector(mockStats)
        ..throwError = true;
      final errorMonitor = NetworkMonitor(
        receivePort.sendPort,
        NetworkMonitorConfig().toJson(),
        statsCollector: errorCollector,
      );

      final messages = <Map<String, dynamic>>[];
      receivePort.listen((message) {
        if (message is Map<String, dynamic>) {
          messages.add(message);
        }
      });

      await errorMonitor.collectAndSendStats();

      expect(messages.length, equals(1));
      expect(messages.first['type'], equals('error'));
      expect(messages.first['message'], contains('Test error'));
    });
  });
}
