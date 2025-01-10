import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../mesh/models/process_info.dart';
import '../../mesh/process/process_manager.dart';
import '../../mesh/providers/process_manager_provider.dart';

/// Widget za prikaz liste procesa
class ProcessListWidget extends ConsumerWidget {
  final String nodeId;

  const ProcessListWidget({
    super.key,
    required this.nodeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final processesAsync = ref.watch(activeProcessesProvider(nodeId));

    return processesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(
        child: Text(
          'Greška prilikom učitavanja procesa: $error',
          style: TextStyle(color: Colors.red),
        ),
      ),
      data: (processes) {
        if (processes.isEmpty) {
          return const Center(
            child: Text('Nema aktivnih procesa'),
          );
        }

        return ListView.builder(
          itemCount: processes.length,
          itemBuilder: (context, index) {
            final process = processes[index];
            return _ProcessListItem(process: process);
          },
        );
      },
    );
  }
}

/// Widget za prikaz pojedinačnog procesa
class _ProcessListItem extends StatelessWidget {
  final ProcessInfo process;

  const _ProcessListItem({
    required this.process,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(process.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${process.status}'),
            Text('Prioritet: ${process.priority}'),
            Text('CPU: ${process.cpuUsage.toStringAsFixed(1)}%'),
            Text('Memorija: ${process.memoryUsageMb} MB'),
          ],
        ),
        trailing: _buildActionButtons(context),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final key = ProcessKey(
          nodeId: process.nodeId,
          processId: process.id,
        );

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (process.status == ProcessStatus.running)
              IconButton(
                icon: const Icon(Icons.pause),
                onPressed: () async {
                  try {
                    final manager = ref.read(processManagerProvider);
                    await manager.pauseProcess(key);
                  } catch (e) {
                    _showError(
                        context, 'Greška prilikom pauziranja procesa: $e');
                  }
                },
              ),
            if (process.status == ProcessStatus.paused)
              IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: () async {
                  try {
                    final manager = ref.read(processManagerProvider);
                    await manager.resumeProcess(key);
                  } catch (e) {
                    _showError(
                        context, 'Greška prilikom nastavljanja procesa: $e');
                  }
                },
              ),
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: () async {
                try {
                  final manager = ref.read(processManagerProvider);
                  await manager.stopProcess(key);
                } catch (e) {
                  _showError(
                      context, 'Greška prilikom zaustavljanja procesa: $e');
                }
              },
            ),
          ],
        );
      },
    );
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
