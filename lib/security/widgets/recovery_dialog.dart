import 'package:flutter/material.dart';
import '../types/recovery_types.dart';

class RecoveryDialog extends StatefulWidget {
  final List<RecoveryStep> steps;
  final bool autoRecoveryAvailable;
  final Duration estimatedTime;
  final VoidCallback onAutoRecoveryRequested;

  const RecoveryDialog({
    super.key,
    required this.steps,
    required this.autoRecoveryAvailable,
    required this.estimatedTime,
    required this.onAutoRecoveryRequested,
  });

  @override
  State<RecoveryDialog> createState() => _RecoveryDialogState();
}

class _RecoveryDialogState extends State<RecoveryDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Oporavak Sistema'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Procenjeno vreme: ${_formatDuration(widget.estimatedTime)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ...widget.steps.map((step) => _buildStepWidget(step)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Otkaži'),
        ),
        if (widget.autoRecoveryAvailable)
          ElevatedButton(
            onPressed: () {
              widget.onAutoRecoveryRequested();
              Navigator.of(context).pop(true);
            },
            child: const Text('Pokreni Automatski Oporavak'),
          ),
      ],
    );
  }

  Widget _buildStepWidget(RecoveryStep step) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          _buildStatusIcon(step.status),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  step.description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (step.progress > 0)
                  LinearProgressIndicator(value: step.progress),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(RecoveryStatus status) {
    final IconData icon;
    final Color color;

    switch (status) {
      case RecoveryStatus.notStarted:
        icon = Icons.pending;
        color = Colors.grey;
        break;
      case RecoveryStatus.inProgress:
        icon = Icons.refresh;
        color = Colors.blue;
        break;
      case RecoveryStatus.completed:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case RecoveryStatus.failed:
        icon = Icons.error;
        color = Colors.red;
        break;
    }

    return Icon(icon, color: color);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes min ${seconds}s';
  }
}
