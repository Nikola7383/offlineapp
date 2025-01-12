import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/master_admin/master_admin_monitoring_provider.dart';
import 'package:intl/intl.dart';

class MasterAdminMonitoringScreen extends ConsumerStatefulWidget {
  const MasterAdminMonitoringScreen({super.key});

  @override
  ConsumerState<MasterAdminMonitoringScreen> createState() =>
      _MasterAdminMonitoringScreenState();
}

class _MasterAdminMonitoringScreenState
    extends ConsumerState<MasterAdminMonitoringScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(masterAdminMonitoringProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(masterAdminMonitoringProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Master Admin Monitoring'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: state.isLoading
                  ? null
                  : () => ref
                      .read(masterAdminMonitoringProvider.notifier)
                      .refresh(),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Aktivni'),
              Tab(text: 'Na Čekanju'),
              Tab(text: 'Istorija'),
            ],
          ),
        ),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildActiveAdminsTab(state.activeAdmins),
                  _buildPendingAdminsTab(state.pendingAdmins),
                  _buildHistoryTab(state.history),
                ],
              ),
      ),
    );
  }

  Widget _buildActiveAdminsTab(List<AdminInfo> admins) {
    if (admins.isEmpty) {
      return const Center(
        child: Text('Nema aktivnih admin-a'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: admins.length,
      itemBuilder: (context, index) {
        final admin = admins[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            admin.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Aktivan od: ${DateFormat('dd.MM.yyyy').format(admin.activeSince)}',
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => _showAdminOptions(admin),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: admin.seedValidity,
                  backgroundColor: Colors.grey,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Seed validnost'),
                    Text('${(admin.seedValidity * 100).toInt()}%'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Čvorovi', admin.nodeCount.toString()),
                    _buildStatItem('Poruke', admin.messageCount.toString()),
                    _buildStatItem(
                        'Uptime', '${(admin.uptime * 100).toInt()}%'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPendingAdminsTab(List<PendingAdminInfo> admins) {
    if (admins.isEmpty) {
      return const Center(
        child: Text('Nema admin-a na čekanju'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: admins.length,
      itemBuilder: (context, index) {
        final admin = admins[index];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(Icons.person_outline, color: Colors.white),
            ),
            title: Text(admin.name),
            subtitle: Text(
              'Zahtev poslat: ${DateFormat('dd.MM.yyyy').format(admin.requestDate)}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => _approveAdmin(admin),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => _rejectAdmin(admin),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab(List<AdminHistoryEntry> history) {
    if (history.isEmpty) {
      return const Center(
        child: Text('Nema istorije'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final entry = history[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: entry.isSuccess ? Colors.green : Colors.red,
              child: Icon(
                entry.isSuccess ? Icons.check : Icons.close,
                color: Colors.white,
              ),
            ),
            title: Text(entry.name),
            subtitle: Text(
              '${entry.description}: ${DateFormat('dd.MM.yyyy').format(entry.date)}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showHistoryDetails(entry),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  void _showAdminOptions(AdminInfo admin) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  const Icon(Icons.remove_circle_outline, color: Colors.red),
              title: const Text('Opozovi pristup'),
              onTap: () {
                Navigator.pop(context);
                _revokeAdmin(admin);
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Osveži status'),
              onTap: () {
                Navigator.pop(context);
                ref.read(masterAdminMonitoringProvider.notifier).refresh();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showHistoryDetails(AdminHistoryEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(entry.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${entry.isSuccess ? 'Uspešno' : 'Neuspešno'}'),
            const SizedBox(height: 8),
            Text('Datum: ${DateFormat('dd.MM.yyyy HH:mm').format(entry.date)}'),
            const SizedBox(height: 8),
            Text('Opis: ${entry.description}'),
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

  Future<void> _approveAdmin(PendingAdminInfo admin) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Potvrda'),
        content: Text(
            'Da li ste sigurni da želite da odobrite pristup za ${admin.name}?'),
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
      await ref
          .read(masterAdminMonitoringProvider.notifier)
          .approveAdmin(admin.id);
    }
  }

  Future<void> _rejectAdmin(PendingAdminInfo admin) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Potvrda'),
        content: Text(
            'Da li ste sigurni da želite da odbijete zahtev za ${admin.name}?'),
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
      await ref
          .read(masterAdminMonitoringProvider.notifier)
          .rejectAdmin(admin.id);
    }
  }

  Future<void> _revokeAdmin(AdminInfo admin) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Potvrda'),
        content: Text(
            'Da li ste sigurni da želite da opozovete pristup za ${admin.name}?'),
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
      await ref
          .read(masterAdminMonitoringProvider.notifier)
          .revokeAdmin(admin.id);
    }
  }
}
