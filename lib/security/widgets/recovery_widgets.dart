import 'package:flutter/material.dart';
import '../types/recovery_types.dart';

/// Widget za prikaz koraka u procesu oporavka
class RecoveryStepWidget extends StatelessWidget {
  final String title;
  final String description;
  final RecoveryStatus status;
  final double progress;

  const RecoveryStepWidget({
    required this.title,
    required this.description,
    required this.status,
    required this.progress,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getStatusIcon(), color: _getStatusColor()),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (status) {
      case RecoveryStatus.notStarted:
        return Icons.pending;
      case RecoveryStatus.inProgress:
        return Icons.refresh;
      case RecoveryStatus.completed:
        return Icons.check_circle;
      case RecoveryStatus.failed:
        return Icons.error;
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case RecoveryStatus.notStarted:
        return Colors.grey;
      case RecoveryStatus.inProgress:
        return Colors.blue;
      case RecoveryStatus.completed:
        return Colors.green;
      case RecoveryStatus.failed:
        return Colors.red;
    }
  }
}

/// Widget za prikaz detalja o procesu oporavka
class RecoveryDetailsWidget extends StatelessWidget {
  final RecoveryDetails details;

  const RecoveryDetailsWidget({
    required this.details,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ID Procesa: ${details.id}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Vreme početka: ${_formatDateTime(details.timestamp)}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Tip oporavka: ${_getRecoveryTypeText(details.type)}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Text(
          'Opis:',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Text(
          details.description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Text(
          'Logovi:',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        _buildLogsList(context),
      ],
    );
  }

  Widget _buildLogsList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: details.logs
            .map((log) => Text(
                  log,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                ))
            .toList(),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}.${dateTime.month}.${dateTime.year} ${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
  }

  String _getRecoveryTypeText(RecoveryType type) {
    switch (type) {
      case RecoveryType.automatic:
        return 'Automatski';
      case RecoveryType.manual:
        return 'Ručni';
      case RecoveryType.userAssisted:
        return 'Uz pomoć korisnika';
    }
  }
}

/// Dialog za potvrdu akcije oporavka
class RecoveryConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final RecoveryType type;
  final VoidCallback onConfirm;

  const RecoveryConfirmationDialog({
    required this.title,
    required this.message,
    required this.type,
    required this.onConfirm,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(_getTypeIcon(), color: _getTypeColor()),
              const SizedBox(width: 8),
              Text(
                'Tip oporavka: ${_getRecoveryTypeText(type)}',
                style: TextStyle(
                  color: _getTypeColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Otkaži'),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _getTypeColor(),
          ),
          child: const Text('Potvrdi'),
        ),
      ],
    );
  }

  IconData _getTypeIcon() {
    switch (type) {
      case RecoveryType.automatic:
        return Icons.auto_fix_high;
      case RecoveryType.manual:
        return Icons.build;
      case RecoveryType.userAssisted:
        return Icons.person;
    }
  }

  Color _getTypeColor() {
    switch (type) {
      case RecoveryType.automatic:
        return Colors.blue;
      case RecoveryType.manual:
        return Colors.orange;
      case RecoveryType.userAssisted:
        return Colors.green;
    }
  }

  String _getRecoveryTypeText(RecoveryType type) {
    switch (type) {
      case RecoveryType.automatic:
        return 'Automatski';
      case RecoveryType.manual:
        return 'Ručni';
      case RecoveryType.userAssisted:
        return 'Uz pomoć korisnika';
    }
  }
}
