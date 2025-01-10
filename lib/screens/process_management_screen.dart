import 'package:flutter/material.dart';
import '../widgets/process/process_list_widget.dart';
import '../widgets/process/process_control_widget.dart';

/// Ekran za upravljanje procesima
class ProcessManagementScreen extends StatelessWidget {
  final String nodeId;

  const ProcessManagementScreen({
    super.key,
    required this.nodeId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upravljanje procesima'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProcessControlWidget(nodeId: nodeId),
            const SizedBox(height: 16),
            Expanded(
              child: ProcessListWidget(nodeId: nodeId),
            ),
          ],
        ),
      ),
    );
  }
}
