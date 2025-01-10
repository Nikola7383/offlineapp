import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/broadcast/broadcast_provider.dart';
import '../../models/broadcast/broadcast_message.dart';

class BroadcastListScreen extends ConsumerWidget {
  const BroadcastListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final broadcasts = ref.watch(broadcastsProvider);
    final urgentBroadcasts = ref.watch(urgentBroadcastsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Broadcast Poruke'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(broadcastsProvider.notifier).refresh();
              ref.read(urgentBroadcastsProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Hitne poruke
          urgentBroadcasts.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Greška: $error'),
            ),
            data: (messages) {
              if (messages.isEmpty) return const SizedBox.shrink();
              return Container(
                color: Colors.red.shade50,
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'HITNE PORUKE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        return _BroadcastCard(
                          message: messages[index],
                          isUrgent: true,
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),

          // Regularne poruke
          Expanded(
            child: broadcasts.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Greška: $error'),
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(
                    child: Text('Nema aktivnih poruka'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _BroadcastCard(
                      message: messages[index],
                      isUrgent: false,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BroadcastCard extends StatelessWidget {
  final BroadcastMessage message;
  final bool isUrgent;

  const _BroadcastCard({
    required this.message,
    required this.isUrgent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        title: Text(message.content),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Poslato: ${_formatDate(message.createdAt)}'),
            if (message.receivedByIds.isNotEmpty)
              Text('Primljeno od: ${message.receivedByIds.length} korisnika'),
          ],
        ),
        trailing: isUrgent
            ? const Icon(Icons.warning, color: Colors.red)
            : const Icon(Icons.message),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute}';
  }
}
