import 'package:flutter/material.dart';
import '../mesh/secure_mesh_network.dart';
import '../mesh/security/security_types.dart';

class SecurityMonitorScreen extends StatefulWidget {
  final SecureMeshNetwork network;

  SecurityMonitorScreen({required this.network});

  @override
  _SecurityMonitorScreenState createState() => _SecurityMonitorScreenState();
}

class _SecurityMonitorScreenState extends State<SecurityMonitorScreen> {
  final List<SecurityEvent> _events = [];
  final Map<SecurityEvent, int> _eventCounts = {};
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _listenToSecurityEvents();
  }

  void _listenToSecurityEvents() {
    widget.network.securityEvents.listen((event) {
      setState(() {
        _events.insert(0, event);
        _eventCounts[event] = (_eventCounts[event] ?? 0) + 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bezbednosni Monitor'),
        actions: [
          IconButton(
            icon: Icon(Icons.security),
            onPressed: _showSecurityStatus,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSecurityOverview(),
          Expanded(
            child: _buildEventList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSecurityDetails,
        child: Icon(Icons.analytics),
        tooltip: 'Analiza bezbednosti',
      ),
    );
  }

  Widget _buildSecurityOverview() {
    final isCompromised = widget.network.isCompromised;

    return Container(
      padding: EdgeInsets.all(16),
      color: isCompromised ? Colors.red[100] : Colors.green[100],
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status Sistema:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Chip(
                label: Text(
                  isCompromised ? 'KOMPROMITOVAN' : 'BEZBEDAN',
                ),
                backgroundColor: isCompromised ? Colors.red : Colors.green,
                labelStyle: TextStyle(color: Colors.white),
              ),
            ],
          ),
          if (_isExpanded) ...[
            SizedBox(height: 8),
            _buildSecurityMetrics(),
          ],
          IconButton(
            icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
            onPressed: () => setState(() => _isExpanded = !_isExpanded),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityMetrics() {
    return Column(
      children: [
        _buildMetricRow(
          'Detektovani napadi:',
          _eventCounts[SecurityEvent.attackDetected]?.toString() ?? '0',
          Colors.red,
        ),
        _buildMetricRow(
          'Anomalije:',
          _eventCounts[SecurityEvent.anomalyDetected]?.toString() ?? '0',
          Colors.orange,
        ),
        _buildMetricRow(
          'Phoenix regeneracije:',
          _eventCounts[SecurityEvent.phoenixRegeneration]?.toString() ?? '0',
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList() {
    if (_events.isEmpty) {
      return Center(
        child: Text('Nema bezbednosnih događaja'),
      );
    }

    return ListView.builder(
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        return _buildEventTile(event);
      },
    );
  }

  Widget _buildEventTile(SecurityEvent event) {
    IconData icon;
    Color color;
    String title;

    switch (event) {
      case SecurityEvent.attackDetected:
        icon = Icons.warning;
        color = Colors.red;
        title = 'Detektovan napad';
        break;
      case SecurityEvent.protocolCompromised:
        icon = Icons.security;
        color = Colors.orange;
        title = 'Protokol kompromitovan';
        break;
      case SecurityEvent.keyCompromised:
        icon = Icons.key;
        color = Colors.red;
        title = 'Ključ kompromitovan';
        break;
      case SecurityEvent.anomalyDetected:
        icon = Icons.bug_report;
        color = Colors.amber;
        title = 'Detektovana anomalija';
        break;
      case SecurityEvent.phoenixRegeneration:
        icon = Icons.autorenew;
        color = Colors.blue;
        title = 'Phoenix regeneracija';
        break;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(DateTime.now().toString()),
      trailing: Icon(Icons.chevron_right),
      onTap: () => _showEventDetails(event),
    );
  }

  void _showSecurityStatus() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Status Sistema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Aktivni čvorovi: ${widget.network.nodes.length}'),
            Text('Nivo enkripcije: Advanced'),
            Text('Poslednja provera: ${DateTime.now()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Zatvori'),
          ),
        ],
      ),
    );
  }

  void _showEventDetails(SecurityEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalji Događaja'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tip: $event'),
            Text('Vreme: ${DateTime.now()}'),
            Text('Ozbiljnost: Visoka'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Zatvori'),
          ),
        ],
      ),
    );
  }

  void _showSecurityDetails() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Analiza Bezbednosti',
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 16),
            _buildSecurityMetrics(),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Zatvori'),
            ),
          ],
        ),
      ),
    );
  }
}
