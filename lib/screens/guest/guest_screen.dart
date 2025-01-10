import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/guest/guest_provider.dart';
import '../broadcast/broadcast_list_screen.dart';
import '../broadcast/create_broadcast_screen.dart';

class GuestScreen extends ConsumerWidget {
  const GuestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guestState = ref.watch(guestProvider);

    return guestState.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Greška: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(guestProvider.notifier).refresh(),
                child: const Text('Pokušaj ponovo'),
              ),
            ],
          ),
        ),
      ),
      data: (guest) {
        if (guest == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Greška pri kreiranju guest naloga'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.read(guestProvider.notifier).refresh(),
                    child: const Text('Pokušaj ponovo'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Guest Pristup'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => ref.read(guestProvider.notifier).refresh(),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID Uređaja: ${guest.deviceId}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Važi do: ${guest.expiresAt.toLocal()}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Status: ${guest.isActive ? "Aktivan" : "Neaktivan"}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: guest.isActive ? Colors.green : Colors.red,
                      ),
                ),
                if (guest.isExpired) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Nalog je istekao',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.red,
                        ),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const BroadcastListScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.list),
                        label: const Text('Pregled Poruka'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: guest.canReceiveBroadcasts
                            ? () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const CreateBroadcastScreen(),
                                  ),
                                )
                            : null,
                        icon: const Icon(Icons.send),
                        label: const Text('Nova Poruka'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Primljene poruke: ${guest.receivedBroadcastIds.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: guest.receivedBroadcastIds.length,
                    itemBuilder: (context, index) {
                      final broadcastId = guest.receivedBroadcastIds[index];
                      return ListTile(
                        title: Text('Poruka #${index + 1}'),
                        subtitle: Text('ID: $broadcastId'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
