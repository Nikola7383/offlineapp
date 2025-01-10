import 'dart:async';
import 'dart:io';
import 'dart:isolate';

/// Konfiguracija za network monitor
class NetworkMonitorConfig {
  final Duration sampleInterval;
  final List<String> interfacesToMonitor;
  final int maxSamplesPerReport;
  final bool includePerProcessStats;

  const NetworkMonitorConfig({
    this.sampleInterval = const Duration(seconds: 1),
    this.interfacesToMonitor = const ['all'],
    this.maxSamplesPerReport = 60,
    this.includePerProcessStats = false,
  });

  Map<String, dynamic> toJson() => {
        'sampleInterval': sampleInterval.inMilliseconds,
        'interfacesToMonitor': interfacesToMonitor,
        'maxSamplesPerReport': maxSamplesPerReport,
        'includePerProcessStats': includePerProcessStats,
      };

  factory NetworkMonitorConfig.fromJson(Map<String, dynamic> json) {
    return NetworkMonitorConfig(
      sampleInterval: Duration(milliseconds: json['sampleInterval'] as int),
      interfacesToMonitor:
          List<String>.from(json['interfacesToMonitor'] as List),
      maxSamplesPerReport: json['maxSamplesPerReport'] as int,
      includePerProcessStats: json['includePerProcessStats'] as bool,
    );
  }
}

/// Statistike mrežnog interfejsa
class NetworkInterfaceStats {
  final String name;
  final int bytesReceived;
  final int bytesSent;
  final int packetsReceived;
  final int packetsSent;
  final int errors;
  final int drops;
  final DateTime timestamp;

  const NetworkInterfaceStats({
    required this.name,
    required this.bytesReceived,
    required this.bytesSent,
    required this.packetsReceived,
    required this.packetsSent,
    required this.errors,
    required this.drops,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'bytesReceived': bytesReceived,
        'bytesSent': bytesSent,
        'packetsReceived': packetsReceived,
        'packetsSent': packetsSent,
        'errors': errors,
        'drops': drops,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Apstraktna klasa za prikupljanje mrežnih statistika
abstract class NetworkStatsCollector {
  Future<List<NetworkInterfaceStats>> collectStats();
}

/// Implementacija prikupljanja mrežnih statistika
class NetworkStatsCollectorImpl implements NetworkStatsCollector {
  @override
  Future<List<NetworkInterfaceStats>> collectStats() async {
    final stats = <NetworkInterfaceStats>[];
    final interfaces = await NetworkInterface.list();

    for (final interface in interfaces) {
      try {
        final interfaceStats = await _collectInterfaceStats(interface);
        if (interfaceStats != null) {
          stats.add(interfaceStats);
        }
      } catch (e) {
        print(
            'Greška prilikom prikupljanja statistika za ${interface.name}: $e');
      }
    }

    return stats;
  }

  Future<NetworkInterfaceStats?> _collectInterfaceStats(
    NetworkInterface interface,
  ) async {
    // TODO: Implementirati platformski specifično prikupljanje statistika
    // Ovo je mock implementacija
    final now = DateTime.now();
    final random = DateTime.now().millisecondsSinceEpoch;

    return NetworkInterfaceStats(
      name: interface.name,
      bytesReceived: random % 1000000,
      bytesSent: (random + 100) % 1000000,
      packetsReceived: random % 1000,
      packetsSent: (random + 100) % 1000,
      errors: random % 10,
      drops: random % 5,
      timestamp: now,
    );
  }
}

/// Prati mrežni saobraćaj i prikuplja statistike
class NetworkMonitor {
  final SendPort sendPort;
  final NetworkMonitorConfig config;
  final NetworkStatsCollector statsCollector;
  final Map<String, NetworkInterfaceStats> _lastStats = {};
  Timer? sampleTimer;
  bool isRunning = false;

  NetworkMonitor(
    this.sendPort,
    Map<String, dynamic> configMap, {
    NetworkStatsCollector? statsCollector,
  })  : config = NetworkMonitorConfig.fromJson(configMap),
        statsCollector = statsCollector ?? NetworkStatsCollectorImpl();

  /// Pokreće monitoring
  void start() {
    if (isRunning) return;
    isRunning = true;

    sampleTimer = Timer.periodic(config.sampleInterval, (_) {
      collectAndSendStats();
    });
  }

  /// Zaustavlja monitoring
  void stop() {
    isRunning = false;
    sampleTimer?.cancel();
    sampleTimer = null;
  }

  /// Prikuplja i šalje statistike
  Future<void> collectAndSendStats() async {
    try {
      final stats = await collectNetworkStats();
      if (stats.isNotEmpty) {
        sendPort.send({
          'type': 'stats',
          'data': stats.map((s) => s.toJson()).toList(),
        });
      }
    } catch (e) {
      sendPort.send({
        'type': 'error',
        'message': 'Greška prilikom prikupljanja statistika: $e',
      });
    }
  }

  /// Prikuplja statistike mrežnih interfejsa
  Future<List<NetworkInterfaceStats>> collectNetworkStats() async {
    final stats = await statsCollector.collectStats();
    return stats.where((s) => _shouldMonitorInterface(s.name)).toList();
  }

  /// Proverava da li treba pratiti interfejs
  bool _shouldMonitorInterface(String name) {
    if (config.interfacesToMonitor.contains('all')) return true;
    return config.interfacesToMonitor.contains(name);
  }
}

/// Mock implementacija prikupljanja statistika za testiranje
class MockNetworkStatsCollector implements NetworkStatsCollector {
  final List<NetworkInterfaceStats> mockStats;
  bool _throwError = false;

  MockNetworkStatsCollector(this.mockStats);

  set throwError(bool value) => _throwError = value;

  @override
  Future<List<NetworkInterfaceStats>> collectStats() async {
    if (_throwError) {
      throw Exception('Test error');
    }
    return mockStats;
  }
}

/// Pokreće network monitor u isolate-u
void startNetworkMonitor(Map<String, dynamic> message) {
  final sendPort = message['sendPort'] as SendPort;
  final config = message['config'] as Map<String, dynamic>;

  final monitor = NetworkMonitor(sendPort, config);
  monitor.start();

  // Slušaj komande
  final receivePort = ReceivePort();
  sendPort.send({'type': 'ready', 'port': receivePort.sendPort});

  receivePort.listen((message) {
    if (message is Map<String, dynamic>) {
      switch (message['command']) {
        case 'stop':
          monitor.stop();
          receivePort.close();
          break;
      }
    }
  });
}
