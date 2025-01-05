import 'package:flutter/material.dart';
import '../../core/models/connection_models.dart';
import '../../core/models/sync_models.dart';
import '../../core/services/service_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoSync = true;
  Set<ConnectionType> _enabledConnections = {
    ConnectionType.wifi,
    ConnectionType.cellular
  };
  int _syncInterval = 15;
  bool _encryptionEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // TODO: Load from shared preferences
    setState(() {
      _autoSync = true;
      _enabledConnections = Services.connection.availableTypes;
      _syncInterval = 15;
      _encryptionEnabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Sync Settings'),
          SwitchListTile(
            title: const Text('Auto Sync'),
            subtitle: const Text('Automatically sync when online'),
            value: _autoSync,
            onChanged: (value) => setState(() => _autoSync = value),
          ),
          ListTile(
            title: const Text('Sync Interval'),
            subtitle: Text('Every $_syncInterval minutes'),
            trailing: DropdownButton<int>(
              value: _syncInterval,
              items: [5, 15, 30, 60].map((minutes) {
                return DropdownMenuItem(
                  value: minutes,
                  child: Text('$minutes min'),
                );
              }).toList(),
              onChanged: (value) => setState(() => _syncInterval = value!),
            ),
          ),
          _buildSectionHeader('Connection Settings'),
          CheckboxListTile(
            title: const Text('WiFi'),
            subtitle: Text(
              Services.connection.currentStatus.activeTypes
                      .contains(ConnectionType.wifi)
                  ? 'Connected'
                  : 'Disconnected',
            ),
            value: _enabledConnections.contains(ConnectionType.wifi),
            onChanged: (value) => _toggleConnection(ConnectionType.wifi),
          ),
          CheckboxListTile(
            title: const Text('Cellular'),
            subtitle: Text(
              Services.connection.currentStatus.activeTypes
                      .contains(ConnectionType.cellular)
                  ? 'Connected'
                  : 'Disconnected',
            ),
            value: _enabledConnections.contains(ConnectionType.cellular),
            onChanged: (value) => _toggleConnection(ConnectionType.cellular),
          ),
          _buildSectionHeader('Security'),
          SwitchListTile(
            title: const Text('Encryption'),
            subtitle: const Text('Encrypt stored messages'),
            value: _encryptionEnabled,
            onChanged: (value) => setState(() => _encryptionEnabled = value),
          ),
          _buildSectionHeader('Storage'),
          ListTile(
            title: const Text('Clear Local Data'),
            subtitle: const Text('Delete all stored messages'),
            trailing: const Icon(Icons.delete_forever),
            onTap: _showClearDataDialog,
          ),
          _buildSectionHeader('Debug'),
          ListTile(
            title: const Text('Sync Status'),
            subtitle: _buildSyncStatus(),
            trailing: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => Services.sync.sync(),
            ),
          ),
          ListTile(
            title: const Text('Connection Test'),
            subtitle: _buildConnectionStatus(),
            trailing: IconButton(
              icon: const Icon(Icons.network_check),
              onPressed: () => Services.connection.checkConnection(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildSyncStatus() {
    return StreamBuilder<SyncStatus>(
      stream: _getSyncStatusStream(),
      builder: (context, snapshot) {
        final status = snapshot.data ?? Services.sync.status;
        return Text(status.toString().split('.').last);
      },
    );
  }

  Widget _buildConnectionStatus() {
    return StreamBuilder<ConnectionStatus>(
      stream: Services.connection.statusStream,
      initialData: Services.connection.currentStatus,
      builder: (context, snapshot) {
        final status = snapshot.data ?? Services.connection.currentStatus;
        return Text(
          status.isConnected
              ? 'Connected (${status.activeTypes.first.toString().split('.').last})'
              : 'Disconnected',
        );
      },
    );
  }

  void _toggleConnection(ConnectionType type) {
    setState(() {
      if (_enabledConnections.contains(type)) {
        _enabledConnections.remove(type);
        Services.connection.disable(type);
      } else {
        _enabledConnections.add(type);
        Services.connection.enable(type);
      }
    });
  }

  Future<void> _showClearDataDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will delete all stored messages and cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('CLEAR'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await Services.storage.clearMessages();
      await Services.sync.clearQueue();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data cleared')),
        );
      }
    }
  }

  Stream<SyncStatus> _getSyncStatusStream() async* {
    while (true) {
      yield Services.sync.status;
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
}
