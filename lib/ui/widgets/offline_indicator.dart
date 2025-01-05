import 'package:flutter/material.dart';
import '../../core/models/connection_models.dart';
import '../../core/services/service_helper.dart';

class OfflineIndicator extends StatefulWidget {
  const OfflineIndicator({super.key});

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator> {
  late Stream<ConnectionStatus> _connectionStream;

  @override
  void initState() {
    super.initState();
    _connectionStream = Services.connection.statusStream;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectionStatus>(
      stream: _connectionStream,
      initialData: Services.connection.currentStatus,
      builder: (context, snapshot) {
        final isOnline = snapshot.data?.isConnected ?? false;

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          color: isOnline ? Colors.green : Colors.orange,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isOnline ? Icons.cloud_done : Icons.cloud_off,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                isOnline ? 'Online' : 'Offline Mode',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SyncStatusBadge extends StatefulWidget {
  const SyncStatusBadge({super.key});

  @override
  State<SyncStatusBadge> createState() => _SyncStatusBadgeState();
}

class _SyncStatusBadgeState extends State<SyncStatusBadge> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream: _getPendingMessagesStream(),
      builder: (context, snapshot) {
        final count = snapshot.data?.length ?? 0;
        if (count == 0) return const SizedBox.shrink();

        return Badge(
          label: Text('$count'),
          child: const Icon(Icons.sync),
        );
      },
    );
  }

  Stream<List<Message>> _getPendingMessagesStream() async* {
    while (true) {
      final result = await Services.sync.getPendingMessages();
      yield result.data ?? [];
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}
