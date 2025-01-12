import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/secret_master/secret_master_provider.dart';
import 'qr_generator_screen.dart';
import 'sound_generator_screen.dart';
import 'master_admin_monitoring_screen.dart';

class SecretMasterDashboard extends ConsumerStatefulWidget {
  const SecretMasterDashboard({super.key});

  @override
  ConsumerState<SecretMasterDashboard> createState() =>
      _SecretMasterDashboardState();
}

class _SecretMasterDashboardState extends ConsumerState<SecretMasterDashboard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(secretMasterProvider.notifier).refreshAdminStatus());
  }

  void _navigateToQRGenerator() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const QRGeneratorScreen(),
      ),
    );
  }

  void _navigateToSoundGenerator() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SoundGeneratorScreen(),
      ),
    );
  }

  void _navigateToMasterAdminMonitoring() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MasterAdminMonitoringScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(secretMasterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Secret Master Dashboard'),
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
                : () => ref
                    .read(secretMasterProvider.notifier)
                    .refreshAdminStatus(),
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
                              'Sistemski Status',
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
                                  'Aktivni Admini',
                                  state.activeAdmins.length.toString(),
                                  Colors.green,
                                ),
                                _buildStatusIndicator(
                                  'Na Čekanju',
                                  state.pendingAdmins.length.toString(),
                                  Colors.orange,
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
                                  icon: Icons.qr_code,
                                  label: 'Generiši QR',
                                  isLoading: state.isGeneratingQR,
                                  onPressed: _navigateToQRGenerator,
                                ),
                                _buildActionButton(
                                  icon: Icons.volume_up,
                                  label: 'Zvučni Signal',
                                  isLoading: state.isGeneratingSound,
                                  onPressed: _navigateToSoundGenerator,
                                ),
                                _buildActionButton(
                                  icon: Icons.admin_panel_settings,
                                  label: 'Master Admin',
                                  onPressed: _navigateToMasterAdminMonitoring,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Monitoring sekcija
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
                                    'Master Admin Monitoring',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _navigateToMasterAdminMonitoring,
                                    child: const Text('Prikaži sve'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: state.activeAdmins.length +
                                      state.pendingAdmins.length,
                                  itemBuilder: (context, index) {
                                    if (index < state.activeAdmins.length) {
                                      final admin = state.activeAdmins[index];
                                      return _buildAdminListTile(
                                        admin: admin,
                                        isActive: true,
                                        onAction: () => ref
                                            .read(secretMasterProvider.notifier)
                                            .revokeAdmin(admin),
                                        actionIcon: Icons.remove_circle_outline,
                                        actionColor: Colors.red,
                                      );
                                    } else {
                                      final admin = state.pendingAdmins[
                                          index - state.activeAdmins.length];
                                      return _buildAdminListTile(
                                        admin: admin,
                                        isActive: false,
                                        onAction: () => ref
                                            .read(secretMasterProvider.notifier)
                                            .approveAdmin(admin),
                                        actionIcon: Icons.check_circle_outline,
                                        actionColor: Colors.green,
                                      );
                                    }
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(icon, size: 30),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }

  Widget _buildAdminListTile({
    required String admin,
    required bool isActive,
    required VoidCallback onAction,
    required IconData actionIcon,
    required Color actionColor,
  }) {
    return ListTile(
      leading: Icon(
        Icons.person,
        color: isActive ? Colors.green : Colors.orange,
      ),
      title: Text(admin),
      subtitle: Text(isActive ? 'Aktivan' : 'Na čekanju'),
      trailing: IconButton(
        icon: Icon(actionIcon, color: actionColor),
        onPressed: onAction,
      ),
    );
  }
}
