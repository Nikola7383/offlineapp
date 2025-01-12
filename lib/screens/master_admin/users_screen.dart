import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/master_admin/users_provider.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(usersProvider.notifier).refreshUsers());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Korisnici'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: state.isLoading
                ? null
                : () => ref.read(usersProvider.notifier).refreshUsers(),
          ),
        ],
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status sekcija
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Status Korisnika',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatusIndicator(
                                  'Aktivni',
                                  state.activeUsers.toString(),
                                  Colors.green,
                                ),
                                _buildStatusIndicator(
                                  'Neaktivni',
                                  state.inactiveUsers.toString(),
                                  Colors.red,
                                ),
                                _buildStatusIndicator(
                                  'Ukupno',
                                  (state.activeUsers + state.inactiveUsers)
                                      .toString(),
                                  Colors.blue,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Lista korisnika
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Lista Korisnika',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  DropdownButton<String>(
                                    value: state.filter,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'all',
                                        child: Text('Svi'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'active',
                                        child: Text('Aktivni'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'inactive',
                                        child: Text('Neaktivni'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) {
                                        ref
                                            .read(usersProvider.notifier)
                                            .setFilter(value);
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: state.filteredUsers.length,
                                  itemBuilder: (context, index) {
                                    final user = state.filteredUsers[index];
                                    return Card(
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: user.isActive
                                              ? Colors.green
                                              : Colors.red,
                                          child: Icon(
                                            user.isActive
                                                ? Icons.check
                                                : Icons.close,
                                            color: Colors.white,
                                          ),
                                        ),
                                        title: Text(user.name),
                                        subtitle: Text(
                                            'ID: ${user.id}\nUloga: ${user.role}\nPoslednja aktivnost: ${user.lastActivity}'),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.more_vert),
                                          onPressed: () =>
                                              _showUserOptions(user),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatusIndicator(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  void _showUserOptions(UserInfo user) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Detalji'),
              onTap: () {
                Navigator.pop(context);
                _showUserDetails(user);
              },
            ),
            if (!user.isActive)
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Aktiviraj korisnika'),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(usersProvider.notifier).activateUser(user.id);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Ukloni korisnika'),
              onTap: () {
                Navigator.pop(context);
                _confirmUserRemoval(user);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUserDetails(UserInfo user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${user.id}'),
            const SizedBox(height: 8),
            Text('Status: ${user.isActive ? 'Aktivan' : 'Neaktivan'}'),
            const SizedBox(height: 8),
            Text('Uloga: ${user.role}'),
            const SizedBox(height: 8),
            Text('Poslednja aktivnost: ${user.lastActivity}'),
            const SizedBox(height: 8),
            Text('Broj poruka: ${user.messageCount}'),
            const SizedBox(height: 8),
            Text('Uptime: ${(user.uptime * 100).toInt()}%'),
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

  Future<void> _confirmUserRemoval(UserInfo user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Potvrda'),
        content: Text(
            'Da li ste sigurni da želite da uklonite korisnika "${user.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Odustani'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Potvrdi'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(usersProvider.notifier).removeUser(user.id);
    }
  }
}
