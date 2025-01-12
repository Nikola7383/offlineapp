import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/master_admin/master_admin_provider.dart';

class MasterAdminDashboard extends ConsumerStatefulWidget {
  const MasterAdminDashboard({super.key});

  @override
  ConsumerState<MasterAdminDashboard> createState() =>
      _MasterAdminDashboardState();
}

class _MasterAdminDashboardState extends ConsumerState<MasterAdminDashboard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(masterAdminProvider.notifier).refreshStatus());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(masterAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Master Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.security),
            onPressed: () {
              // TODO: Implementirati security status pregled
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: state.isLoading
                ? null
                : () => ref.read(masterAdminProvider.notifier).refreshStatus(),
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
                              'Status Sistema',
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
                                  'Aktivni Čvorovi',
                                  state.activeNodes.toString(),
                                  Colors.green,
                                ),
                                _buildStatusIndicator(
                                  'Seed Validnost',
                                  '${(state.seedValidity * 100).toInt()}%',
                                  state.seedValidity > 0.7
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Akcije sekcija
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Brze Akcije',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildActionButton(
                                  icon: Icons.device_hub,
                                  label: 'Čvorovi',
                                  onPressed: () {
                                    // TODO: Implementirati pregled čvorova
                                  },
                                ),
                                _buildActionButton(
                                  icon: Icons.message,
                                  label: 'Poruke',
                                  onPressed: () {
                                    // TODO: Implementirati pregled poruka
                                  },
                                ),
                                _buildActionButton(
                                  icon: Icons.people,
                                  label: 'Korisnici',
                                  onPressed: () {
                                    // TODO: Implementirati pregled korisnika
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Statistika sekcija
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
                                    'Statistika',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // TODO: Implementirati detaljnu statistiku
                                    },
                                    child: const Text('Detaljno'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: ListView(
                                  children: [
                                    _buildStatisticTile(
                                      'Ukupno poruka',
                                      state.totalMessages.toString(),
                                      Icons.message,
                                    ),
                                    _buildStatisticTile(
                                      'Aktivni korisnici',
                                      state.activeUsers.toString(),
                                      Icons.people,
                                    ),
                                    _buildStatisticTile(
                                      'Prosečno vreme odziva',
                                      '${state.averageResponseTime.toStringAsFixed(2)}ms',
                                      Icons.timer,
                                    ),
                                    _buildStatisticTile(
                                      'Uptime',
                                      '${(state.uptime * 100).toInt()}%',
                                      Icons.access_time,
                                    ),
                                  ],
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
          ),
          child: Icon(icon, size: 30),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }

  Widget _buildStatisticTile(String label, String value, IconData icon) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
        child: Icon(icon, color: Theme.of(context).primaryColor),
      ),
      title: Text(label),
      trailing: Text(
        value,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
