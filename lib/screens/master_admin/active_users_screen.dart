import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/master_admin/active_users_provider.dart';

class ActiveUsersScreen extends ConsumerStatefulWidget {
  const ActiveUsersScreen({super.key});

  @override
  ConsumerState<ActiveUsersScreen> createState() => _ActiveUsersScreenState();
}

class _ActiveUsersScreenState extends ConsumerState<ActiveUsersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(activeUsersProvider.notifier).loadUsers());
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
            onPressed: state.isLoading
                ? null
                : () => ref.read(activeUsersProvider.notifier).loadUsers(),
          ),
        ],
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Statistika
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Theme.of(context).colorScheme.surface,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard(
                          'Ukupno',
                          state.totalUsers.toString(),
                          Icons.people,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          'Online',
                          state.onlineUsers.toString(),
                          Icons.check_circle,
                          Colors.green,
                        ),
                        _buildStatCard(
                          'Offline',
                          state.offlineUsers.toString(),
                          Icons.offline_bolt,
                          Colors.grey,
                        ),
                      ],
                    ),
                  ),

                  // Lista korisnika
                  Expanded(
                    child: state.users.isEmpty
                        ? const Center(
                            child: Text('Nema aktivnih korisnika'),
                          )
                        : ListView.builder(
                            itemCount: state.users.length,
                            itemBuilder: (context, index) {
                              final user = state.users[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: user.isOnline
                                        ? Colors.green
                                        : Colors.grey,
                                    child: Text(
                                      user.name[0].toUpperCase(),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  title: Text(user.name),
                                  subtitle: Text(user.role),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) =>
                                        _handleUserAction(value, user),
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'details',
                                        child: Text('Detalji'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'message',
                                        child: Text('Pošalji poruku'),
                                      ),
                                      if (user.isOnline)
                                        const PopupMenuItem(
                                          value: 'disconnect',
                                          child: Text('Prekini vezu'),
                                        ),
                                      const PopupMenuItem(
                                        value: 'block',
                                        child: Text('Blokiraj'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFilterDialog,
        child: const Icon(Icons.filter_list),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleUserAction(String action, ActiveUser user) async {
    switch (action) {
      case 'details':
        _showUserDetails(user);
        break;
      case 'message':
        _showMessageDialog(user);
        break;
      case 'disconnect':
        _disconnectUser(user);
        break;
      case 'block':
        _showBlockDialog(user);
        break;
    }
  }

  void _showUserDetails(ActiveUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Uloga: ${user.role}'),
            const SizedBox(height: 8),
            Text('Status: ${user.isOnline ? "Online" : "Offline"}'),
            const SizedBox(height: 8),
            Text('Poslednja aktivnost: ${user.lastActivity}'),
            const SizedBox(height: 8),
            Text('IP adresa: ${user.ipAddress}'),
            if (user.location != null) ...[
              const SizedBox(height: 8),
              Text('Lokacija: ${user.location}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Zatvori'),
          ),
        ],
      ),
    );
  }

  void _showMessageDialog(ActiveUser user) {
    final messageController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Poruka za ${user.name}'),
        content: TextField(
          controller: messageController,
          decoration: const InputDecoration(
            hintText: 'Unesite poruku...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Otkaži'),
          ),
          ElevatedButton(
            onPressed: () {
              if (messageController.text.isNotEmpty) {
                ref
                    .read(activeUsersProvider.notifier)
                    .sendMessage(user.id, messageController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Pošalji'),
          ),
        ],
      ),
    );
  }

  Future<void> _disconnectUser(ActiveUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Prekid veze'),
        content: Text(
            'Da li ste sigurni da želite da prekinete vezu sa ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Otkaži'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Prekini vezu'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(activeUsersProvider.notifier).disconnectUser(user.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veza je uspešno prekinuta'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Greška pri prekidu veze: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showBlockDialog(ActiveUser user) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Blokiranje korisnika'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Da li ste sigurni da želite da blokirate ${user.name}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Razlog blokiranja...',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Otkaži'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Blokiraj'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(activeUsersProvider.notifier)
            .blockUser(user.id, reasonController.text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Korisnik je uspešno blokiran'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Greška pri blokiranju: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Online korisnici'),
              value: ref.read(activeUsersProvider).showOnlineOnly,
              onChanged: (value) {
                ref
                    .read(activeUsersProvider.notifier)
                    .toggleOnlineFilter(value ?? false);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            const Text('Uloge:'),
            ...ref.read(activeUsersProvider).availableRoles.map(
                  (role) => CheckboxListTile(
                    title: Text(role),
                    value: ref
                        .read(activeUsersProvider)
                        .selectedRoles
                        .contains(role),
                    onChanged: (value) {
                      ref
                          .read(activeUsersProvider.notifier)
                          .toggleRoleFilter(role);
                      Navigator.pop(context);
                    },
                  ),
                ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(activeUsersProvider.notifier).clearFilters();
              Navigator.pop(context);
            },
            child: const Text('Resetuj'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Zatvori'),
          ),
        ],
      ),
    );
  }
}
