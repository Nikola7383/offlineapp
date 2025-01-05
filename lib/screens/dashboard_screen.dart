import 'package:flutter/material.dart';
import 'seed_management_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Master Admin Dashboard'),
        actions: [
          // Status mreže
          Container(
            padding: const EdgeInsets.all(8.0),
            child: const Row(
              children: [
                Icon(Icons.circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Network Active'),
              ],
            ),
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildDashboardItem(
            'Seed Management',
            Icons.people,
            Colors.blue,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SeedManagementScreen(),
                ),
              );
            },
          ),
          _buildDashboardItem(
            'Network Control',
            Icons.wifi,
            Colors.green,
            () => {/* TODO */},
          ),
          _buildDashboardItem(
            'Broadcast',
            Icons.message,
            Colors.orange,
            () => {/* TODO */},
          ),
          _buildDashboardItem(
            'Security',
            Icons.security,
            Colors.red,
            () => {/* TODO */},
          ),
          _buildDashboardItem(
            'Traffic Light',
            Icons.traffic,
            Colors.amber,
            () => {/* TODO */},
          ),
          _buildDashboardItem(
            'Settings',
            Icons.settings,
            Colors.grey,
            () => {/* TODO */},
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardItem(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
