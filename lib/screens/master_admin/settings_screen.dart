import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/master_admin/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(settingsProvider.notifier).loadSettings());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Podešavanja'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: state.isLoading
                ? null
                : () => ref.read(settingsProvider.notifier).loadSettings(),
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
                    // Mrežna podešavanja
                    _buildSection(
                      'Mrežna Podešavanja',
                      [
                        _buildTextField(
                          'Maksimalan broj čvorova',
                          state.maxNodes.toString(),
                          (value) => _updateMaxNodes(int.tryParse(value)),
                          keyboardType: TextInputType.number,
                        ),
                        _buildTextField(
                          'Interval sinhronizacije (sekunde)',
                          state.syncInterval.toString(),
                          (value) => _updateSyncInterval(int.tryParse(value)),
                          keyboardType: TextInputType.number,
                        ),
                        _buildSwitch(
                          'Automatska sinhronizacija',
                          state.autoSync,
                          (value) => ref
                              .read(settingsProvider.notifier)
                              .updateAutoSync(value),
                        ),
                      ],
                    ),

                    // Bezbednosna podešavanja
                    _buildSection(
                      'Bezbednosna Podešavanja',
                      [
                        _buildDropdown(
                          'Nivo enkripcije',
                          state.encryptionLevel,
                          ['AES-128', 'AES-256', 'ChaCha20'],
                          (value) => ref
                              .read(settingsProvider.notifier)
                              .updateEncryptionLevel(value!),
                        ),
                        _buildSwitch(
                          'Dvofaktorska autentifikacija',
                          state.twoFactorAuth,
                          (value) => ref
                              .read(settingsProvider.notifier)
                              .updateTwoFactorAuth(value),
                        ),
                        _buildTextField(
                          'Vreme sesije (minuti)',
                          state.sessionTimeout.toString(),
                          (value) => _updateSessionTimeout(int.tryParse(value)),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),

                    // Podešavanja logovanja
                    _buildSection(
                      'Podešavanja Logovanja',
                      [
                        _buildDropdown(
                          'Nivo logovanja',
                          state.logLevel,
                          ['ERROR', 'WARNING', 'INFO', 'DEBUG'],
                          (value) => ref
                              .read(settingsProvider.notifier)
                              .updateLogLevel(value!),
                        ),
                        _buildTextField(
                          'Maksimalna veličina loga (MB)',
                          state.maxLogSize.toString(),
                          (value) => _updateMaxLogSize(int.tryParse(value)),
                          keyboardType: TextInputType.number,
                        ),
                        _buildSwitch(
                          'Detaljno logovanje',
                          state.verboseLogging,
                          (value) => ref
                              .read(settingsProvider.notifier)
                              .updateVerboseLogging(value),
                        ),
                      ],
                    ),

                    // Dugmad za akcije
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => _resetToDefaults(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                          child: const Text('Resetuj na podrazumevano'),
                        ),
                        ElevatedButton(
                          onPressed: () => _saveSettings(),
                          child: const Text('Sačuvaj izmene'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: children,
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String value,
    Function(String) onChanged, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: TextEditingController(text: value),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSwitch(
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _updateMaxNodes(int? value) {
    if (value != null && value > 0) {
      ref.read(settingsProvider.notifier).updateMaxNodes(value);
    }
  }

  void _updateSyncInterval(int? value) {
    if (value != null && value > 0) {
      ref.read(settingsProvider.notifier).updateSyncInterval(value);
    }
  }

  void _updateSessionTimeout(int? value) {
    if (value != null && value > 0) {
      ref.read(settingsProvider.notifier).updateSessionTimeout(value);
    }
  }

  void _updateMaxLogSize(int? value) {
    if (value != null && value > 0) {
      ref.read(settingsProvider.notifier).updateMaxLogSize(value);
    }
  }

  Future<void> _resetToDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Potvrda'),
        content: const Text(
            'Da li ste sigurni da želite da resetujete sva podešavanja na podrazumevane vrednosti?'),
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
      await ref.read(settingsProvider.notifier).resetToDefaults();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Podešavanja su resetovana na podrazumevane vrednosti'),
          ),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    try {
      await ref.read(settingsProvider.notifier).saveSettings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Podešavanja su uspešno sačuvana'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška pri čuvanju podešavanja: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
