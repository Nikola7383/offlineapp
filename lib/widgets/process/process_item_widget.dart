import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../mesh/models/process_info.dart';
import '../../mesh/providers/process_manager_provider.dart';

/// Widget za prikaz i upravljanje pojedinačnim procesom
class ProcessItemWidget extends ConsumerWidget {
  final String nodeId;
  final ProcessInfo process;

  const ProcessItemWidget({
    super.key,
    required this.nodeId,
    required this.process,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = ProcessKey(nodeId: nodeId, processId: process.id);
    final control = ref.watch(processControlProvider(key));
    final processAsync = ref.watch(processStatsProvider(key));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 8),
            _buildStats(processAsync),
            const SizedBox(height: 8),
            _buildControls(context, control),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              process.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'ID: ${process.id}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        _buildStatusChip(),
      ],
    );
  }

  Widget _buildStatusChip() {
    Color color;
    IconData icon;

    switch (process.status) {
      case ProcessStatus.running:
        color = Colors.green;
        icon = Icons.play_arrow;
        break;
      case ProcessStatus.paused:
        color = Colors.orange;
        icon = Icons.pause;
        break;
      case ProcessStatus.stopping:
        color = Colors.red;
        icon = Icons.stop;
        break;
      case ProcessStatus.stopped:
        color = Colors.grey;
        icon = Icons.stop;
        break;
      case ProcessStatus.starting:
        color = Colors.blue;
        icon = Icons.refresh;
        break;
      case ProcessStatus.error:
        color = Colors.red;
        icon = Icons.error;
        break;
    }

    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 16),
      label: Text(
        process.status.toString().split('.').last.toUpperCase(),
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }

  Widget _buildStats(AsyncValue<ProcessInfo?> processAsync) {
    return processAsync.when(
      data: (process) {
        if (process == null) return const SizedBox.shrink();

        return Column(
          children: [
            _buildStatRow(
              'CPU',
              '${process.cpuUsage.toStringAsFixed(1)}%',
              Icons.memory,
            ),
            _buildStatRow(
              'Memorija',
              '${process.memoryUsageMb} MB',
              Icons.storage,
            ),
            _buildStatRow(
              'Threadovi',
              process.threadCount.toString(),
              Icons.timeline,
            ),
            _buildStatRow(
              'Otvoreni fajlovi',
              process.openFileCount.toString(),
              Icons.folder_open,
            ),
            _buildStatRow(
              'Mrežne konekcije',
              process.networkConnectionCount.toString(),
              Icons.network_check,
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text(
        'Greška: $error',
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Text(label),
          const Spacer(),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context, ProcessControl control) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (process.status == ProcessStatus.running)
          IconButton(
            icon: const Icon(Icons.pause),
            onPressed: () => _pauseProcess(context, control),
            tooltip: 'Pauziraj proces',
          ),
        if (process.status == ProcessStatus.paused)
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () => _resumeProcess(context, control),
            tooltip: 'Nastavi proces',
          ),
        IconButton(
          icon: const Icon(Icons.stop),
          onPressed: () => _stopProcess(context, control),
          tooltip: 'Zaustavi proces',
        ),
      ],
    );
  }

  Future<void> _pauseProcess(
      BuildContext context, ProcessControl control) async {
    try {
      await control.pause();
    } catch (e) {
      _showError(context, 'Greška prilikom pauziranja procesa: $e');
    }
  }

  Future<void> _resumeProcess(
      BuildContext context, ProcessControl control) async {
    try {
      await control.resume();
    } catch (e) {
      _showError(context, 'Greška prilikom nastavljanja procesa: $e');
    }
  }

  Future<void> _stopProcess(
      BuildContext context, ProcessControl control) async {
    try {
      await control.stop();
    } catch (e) {
      _showError(context, 'Greška prilikom zaustavljanja procesa: $e');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
