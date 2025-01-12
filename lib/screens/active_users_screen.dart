import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/active_users_provider.dart';
import '../models/active_user.dart';

class ActiveUsersScreen extends ConsumerStatefulWidget {
  const ActiveUsersScreen({super.key});

  @override
  ConsumerState<ActiveUsersScreen> createState() => _ActiveUsersScreenState();
}

class _ActiveUsersScreenState extends ConsumerState<ActiveUsersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(activeUsersProvider.notifier).loadActiveUsers(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activeUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktivni Korisnici'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(activeUsersProvider.notifier).loadActiveUsers(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref
                            .read(activeUsersProvider.notifier)
                            .loadActiveUsers(),
                        child: const Text('Pokušaj ponovo'),
                      ),
                    ],
                  ),
                )
              : state.users.isEmpty
                  ? const Center(
                      child: Text('Nema aktivnih korisnika'),
                    )
                  : ListView.builder(
                      itemCount: state.users.length,
                      itemBuilder: (context, index) {
                        final user = state.users[index];
                        return _UserListTile(user: user);
                      },
                    ),
    );
  }
}

class _UserListTile extends StatelessWidget {
  final ActiveUser user;

  const _UserListTile({required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: user.isOnline ? Colors.green : Colors.grey,
        child: Icon(
          Icons.person,
          color: Colors.white,
        ),
      ),
      title: Text(user.username),
      subtitle: Text(user.role),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Poslednja aktivnost:',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            _formatDateTime(user.lastActive),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Upravo sada';
    } else if (difference.inHours < 1) {
      return 'Pre ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Pre ${difference.inHours}h';
    } else {
      return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
    }
  }
}
