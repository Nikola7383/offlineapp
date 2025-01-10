import 'dart:async';
import 'dart:math';

import 'package:secure_event_app/mesh/models/process_key.dart';
import 'package:secure_event_app/mesh/models/process_stats.dart';
import 'package:secure_event_app/mesh/process/process_manager.dart';

class ProcessStatsCollector {
  final ProcessManager _manager;
  final Duration _interval;
  Timer? _timer;
  final _statsController =
      StreamController<Map<ProcessKey, ProcessStats>>.broadcast();

  Stream<Map<ProcessKey, ProcessStats>> get stats => _statsController.stream;

  ProcessStatsCollector({
    required ProcessManager manager,
    Duration interval = const Duration(milliseconds: 100),
  })  : _manager = manager,
        _interval = interval;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (_) => _collectStats());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _collectStats() async {
    final processes = await _manager.getActiveProcesses('');
    if (processes.isEmpty) {
      _statsController.add({});
      return;
    }

    final stats = <ProcessKey, ProcessStats>{};
    final random = Random();

    for (final process in processes) {
      final key = ProcessKey(
        nodeId: process.id.split('_').first,
        processId: process.id,
      );

      stats[key] = ProcessStats(
        cpuUsage: random.nextDouble() * 100,
        memoryUsageMb: random.nextDouble() * 1024,
        threadCount: random.nextInt(20) + 1,
        openFileCount: random.nextInt(50),
        networkConnectionCount: random.nextInt(10),
        timestamp: DateTime.now(),
      );
    }

    _statsController.add(stats);
  }

  void dispose() {
    stop();
    _statsController.close();
  }
}
