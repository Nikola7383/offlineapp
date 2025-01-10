import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:secure_event_app/mesh/models/process_key.dart';
import 'package:secure_event_app/mesh/models/process_stats.dart';
import 'package:secure_event_app/mesh/providers/process_manager_provider.dart';

final processStatsProvider =
    StreamProvider.family<Map<ProcessKey, ProcessStats>, String>((ref, nodeId) {
  final manager = ref.watch(processManagerProvider);
  return manager.stats.map((stats) {
    return Map.fromEntries(
      stats.entries.where((e) => e.key.nodeId == nodeId),
    );
  });
});
