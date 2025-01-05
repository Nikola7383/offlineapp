import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../mesh/monitoring/anomaly_detector.dart';
import '../mesh/secure_mesh_network.dart';

class NetworkAnalyticsScreen extends StatefulWidget {
  final SecureMeshNetwork network;

  NetworkAnalyticsScreen({required this.network});

  @override
  _NetworkAnalyticsScreenState createState() => _NetworkAnalyticsScreenState();
}

class _NetworkAnalyticsScreenState extends State<NetworkAnalyticsScreen> {
  final List<FlSpot> _anomalyScores = [];
  final List<FlSpot> _networkMetrics = [];
  final AnomalyDetector _detector = AnomalyDetector();

  int _selectedMetricIndex = 0;
  bool _showAnomalyThreshold = true;

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  void _startMonitoring() {
    // Periodično prikupljaj metrike
    Future.delayed(Duration(seconds: 1), () async {
      if (!mounted) return;

      final metrics = _NetworkMetrics(
        messageCount: widget.network.messageCount,
        avgMessageSize: widget.network.averageMessageSize,
        messageFrequency: widget.network.messageFrequency,
        uniqueNodes: widget.network.nodes.length,
        networkDensity: widget.network.networkDensity,
        failedAttempts: widget.network.failedAttempts,
        batteryLevel: widget.network.averageBatteryLevel,
        signalStrength: widget.network.averageSignalStrength,
        honeypotHits: widget.network.honeypotHits,
      );

      final score = await _detector.analyzeMetrics(metrics);

      setState(() {
        _anomalyScores.add(FlSpot(
          _anomalyScores.length.toDouble(),
          score,
        ));

        _networkMetrics.add(FlSpot(
          _networkMetrics.length.toDouble(),
          metrics.toVector()[_selectedMetricIndex],
        ));

        // Keep last 100 points
        if (_anomalyScores.length > 100) {
          _anomalyScores.removeAt(0);
          _networkMetrics.removeAt(0);
        }
      });

      _startMonitoring();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mrežna Analitika'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildMetricSelector(),
          Expanded(
            child: _buildCharts(),
          ),
          _buildStatusBar(),
        ],
      ),
    );
  }

  Widget _buildMetricSelector() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: DropdownButton<int>(
        value: _selectedMetricIndex,
        items: [
          DropdownMenuItem(value: 0, child: Text('Broj poruka')),
          DropdownMenuItem(value: 1, child: Text('Prosečna veličina')),
          DropdownMenuItem(value: 2, child: Text('Frekvencija')),
          DropdownMenuItem(value: 3, child: Text('Broj čvorova')),
          DropdownMenuItem(value: 4, child: Text('Gustina mreže')),
          DropdownMenuItem(value: 5, child: Text('Neuspeli pokušaji')),
          DropdownMenuItem(value: 6, child: Text('Nivo baterije')),
          DropdownMenuItem(value: 7, child: Text('Jačina signala')),
          DropdownMenuItem(value: 8, child: Text('Honeypot pogoci')),
        ],
        onChanged: (value) {
          setState(() => _selectedMetricIndex = value!);
        },
      ),
    );
  }

  Widget _buildCharts() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: _buildAnomalyChart(),
          ),
          SizedBox(height: 16),
          Expanded(
            child: _buildMetricChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnomalyChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
          ),
          bottomTitles: SideTitles(showTitles: false),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: _anomalyScores,
            isCurved: true,
            colors: [Colors.red],
            dotData: FlDotData(show: false),
          ),
          if (_showAnomalyThreshold)
            LineChartBarData(
              spots: [
                FlSpot(0, AnomalyDetector.ANOMALY_THRESHOLD),
                FlSpot(100, AnomalyDetector.ANOMALY_THRESHOLD),
              ],
              colors: [Colors.red.withOpacity(0.3)],
              dotData: FlDotData(show: false),
              dashArray: [5, 5],
            ),
        ],
      ),
    );
  }

  Widget _buildMetricChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
          ),
          bottomTitles: SideTitles(showTitles: false),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: _networkMetrics,
            isCurved: true,
            colors: [Colors.blue],
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    final latestScore = _anomalyScores.isEmpty ? 0.0 : _anomalyScores.last.y;

    final isAnomaly = _detector.isAnomaly(latestScore);

    return Container(
      padding: EdgeInsets.all(16),
      color: isAnomaly ? Colors.red[100] : Colors.green[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Status:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            isAnomaly ? 'Detektovana anomalija' : 'Normalno',
            style: TextStyle(
              color: isAnomaly ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Podešavanja'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text('Prikaži prag anomalije'),
              value: _showAnomalyThreshold,
              onChanged: (value) {
                setState(() => _showAnomalyThreshold = value);
                Navigator.pop(context);
              },
            ),
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
}
