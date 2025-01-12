import 'dart:async';
import 'dart:isolate';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'network_monitor.freezed.dart';
part 'network_monitor.g.dart';

abstract class NetworkStatsCollector {
  Future<List<NetworkInterfaceStats>> collectStats();
}

@freezed
class NetworkMonitorConfig with _$NetworkMonitorConfig {
  const factory NetworkMonitorConfig({
    @Default(Duration(seconds: 1)) Duration sampleInterval,
    @Default(['all']) List<String> interfacesToMonitor,
    @Default(60) int maxSamplesPerReport,
    @Default(false) bool includePerProcessStats,
  }) = _NetworkMonitorConfig;

  factory NetworkMonitorConfig.fromJson(Map<String, dynamic> json) =>
      _$NetworkMonitorConfigFromJson(json);
}

@freezed
class NetworkInterfaceStats with _$NetworkInterfaceStats {
  const factory NetworkInterfaceStats({
    required String name,
    required int bytesReceived,
    required int bytesSent,
    required int packetsReceived,
    required int packetsSent,
    required int errors,
    required int drops,
    required DateTime timestamp,
  }) = _NetworkInterfaceStats;

  factory NetworkInterfaceStats.fromJson(Map<String, dynamic> json) =>
      _$NetworkInterfaceStatsFromJson(json);
}

class NetworkMonitor {
  final SendPort sendPort;
  final NetworkMonitorConfig config;
  final NetworkStatsCollector? statsCollector;
  Timer? _timer;
  bool _isRunning = false;

  NetworkMonitor(this.sendPort, Map<String, dynamic> configJson,
      {this.statsCollector})
      : config = NetworkMonitorConfig.fromJson(configJson);

  bool get isRunning => _isRunning;
  Timer? get sampleTimer => _timer;

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _timer =
        Timer.periodic(config.sampleInterval, (_) => collectAndSendStats());
  }

  void stop() {
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
  }

  Future<List<NetworkInterfaceStats>> collectNetworkStats() async {
    final stats = await statsCollector?.collectStats() ?? [];
    if (config.interfacesToMonitor.contains('all')) {
      return stats;
    }
    return stats
        .where((stat) => config.interfacesToMonitor.contains(stat.name))
        .toList();
  }

  Future<void> collectAndSendStats() async {
    try {
      final stats = await collectNetworkStats();
      sendPort.send({
        'type': 'stats',
        'data': stats.map((s) => s.toJson()).toList(),
      });
    } catch (e) {
      sendPort.send({
        'type': 'error',
        'message': e.toString(),
      });
    }
  }
}
