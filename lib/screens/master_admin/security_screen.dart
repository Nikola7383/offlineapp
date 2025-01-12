import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/master_admin/security_provider.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(securityProvider.notifier).loadSecurityInfo());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(securityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bezbednost'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: state.isLoading
                ? null
                : () => ref.read(securityProvider.notifier).loadSecurityInfo(),
          ),
        ],
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status bezbednosti
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Status Bezbednosti',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildSecurityStatus(
                              'Ukupan status',
                              state.overallStatus,
                              state.overallStatusColor,
                            ),
                            const Divider(),
                            _buildSecurityItem(
                              'Aktivne pretnje',
                              state.activeThreats.toString(),
                              state.activeThreats > 0
                                  ? Colors.red
                                  : Colors.green,
                            ),
                            _buildSecurityItem(
                              'Blokirani pokušaji',
                              state.blockedAttempts.toString(),
                              Colors.orange,
                            ),
                            _buildSecurityItem(
                              'Poslednja provera',
                              state.lastCheck,
                              Colors.blue,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Lista pretnji
                    if (state.activeThreats > 0) ...[
                      const Text(
                        'Aktivne Pretnje',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...state.threats.map((threat) => Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    _getThreatLevelColor(threat.level),
                                child: Text(
                                  threat.level[0],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(threat.description),
                              subtitle: Text(
                                  'Izvor: ${threat.source}\nVreme: ${threat.timestamp}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () => _showThreatDetails(threat),
                              ),
                            ),
                          )),
                      const SizedBox(height: 16),
                    ],

                    // Bezbednosne mere
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bezbednosne Mere',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildSecurityMeasure(
                              'Enkripcija',
                              state.encryptionEnabled,
                              state.encryptionDetails,
                            ),
                            _buildSecurityMeasure(
                              'Firewall',
                              state.firewallEnabled,
                              state.firewallDetails,
                            ),
                            _buildSecurityMeasure(
                              'Antivirusna zaštita',
                              state.antivirusEnabled,
                              state.antivirusDetails,
                            ),
                            _buildSecurityMeasure(
                              'Detekcija upada',
                              state.intrusionDetectionEnabled,
                              state.intrusionDetectionDetails,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dugmad za akcije
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _runSecurityScan(),
                          icon: const Icon(Icons.security),
                          label: const Text('Pokreni skeniranje'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showSecurityReport(),
                          icon: const Icon(Icons.assessment),
                          label: const Text('Generiši izveštaj'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSecurityStatus(String label, String status, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.security, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityMeasure(String label, bool enabled, String details) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.error,
            color: enabled ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  details,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSecurityMeasureSettings(label),
          ),
        ],
      ),
    );
  }

  Color _getThreatLevelColor(String level) {
    switch (level.toUpperCase()) {
      case 'HIGH':
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      case 'LOW':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  void _showThreatDetails(SecurityThreat threat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pretnja: ${threat.level}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Opis: ${threat.description}'),
            const SizedBox(height: 8),
            Text('Izvor: ${threat.source}'),
            const SizedBox(height: 8),
            Text('Vreme: ${threat.timestamp}'),
            const SizedBox(height: 8),
            Text('Status: ${threat.status}'),
            if (threat.recommendedAction != null) ...[
              const SizedBox(height: 8),
              Text('Preporučena akcija: ${threat.recommendedAction}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Zatvori'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleThreat(threat);
            },
            child: const Text('Reši pretnju'),
          ),
        ],
      ),
    );
  }

  void _showSecurityMeasureSettings(String measure) {
    // TODO: Implementirati dijalog za podešavanja bezbednosnih mera
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Podešavanja: $measure'),
        content: const Text(
            'Ovde će biti prikazana podešavanja za izabranu bezbednosnu meru.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Zatvori'),
          ),
        ],
      ),
    );
  }

  Future<void> _runSecurityScan() async {
    try {
      await ref.read(securityProvider.notifier).runSecurityScan();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bezbednosno skeniranje je uspešno završeno'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška pri skeniranju: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showSecurityReport() async {
    try {
      final report = await ref.read(securityProvider.notifier).generateReport();
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Bezbednosni Izveštaj'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Datum: ${report.timestamp}'),
                  const SizedBox(height: 16),
                  const Text(
                    'Statistika:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Ukupno pretnji: ${report.totalThreats}'),
                  Text('Rešene pretnje: ${report.resolvedThreats}'),
                  Text('Aktivne pretnje: ${report.activeThreats}'),
                  const SizedBox(height: 16),
                  const Text(
                    'Bezbednosne mere:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Enkripcija: ${report.encryptionStatus}'),
                  Text('Firewall: ${report.firewallStatus}'),
                  Text('Antivirus: ${report.antivirusStatus}'),
                  if (report.recommendations.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Preporuke:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...report.recommendations
                        .map((rec) => Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text('• $rec'),
                            ))
                        .toList(),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Zatvori'),
              ),
              ElevatedButton(
                onPressed: () => _exportReport(report),
                child: const Text('Izvezi PDF'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška pri generisanju izveštaja: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleThreat(SecurityThreat threat) async {
    try {
      await ref.read(securityProvider.notifier).handleThreat(threat.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pretnja je uspešno rešena'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška pri rešavanju pretnje: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportReport(SecurityReport report) async {
    try {
      await ref.read(securityProvider.notifier).exportReportToPdf(report);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izveštaj je uspešno izvezen'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška pri izvozu izveštaja: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
