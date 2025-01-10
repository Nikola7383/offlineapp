import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../mesh/models/process_info.dart';
import '../../mesh/providers/process_manager_provider.dart';

/// Widget za pokretanje novih procesa
class ProcessControlWidget extends ConsumerWidget {
  final String nodeId;

  const ProcessControlWidget({
    super.key,
    required this.nodeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final starter = ref.watch(processStarterProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pokreni novi proces',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ProcessStartButton(
                    icon: Icons.monitor,
                    label: 'Network Monitor',
                    onPressed: () => _startNetworkMonitor(context, starter),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ProcessStartButton(
                    icon: Icons.security,
                    label: 'Security Scanner',
                    onPressed: () => _startSecurityScanner(context, starter),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startNetworkMonitor(
    BuildContext context,
    ProcessStarter starter,
  ) async {
    try {
      await starter.startNetworkMonitor(nodeId);
      if (context.mounted) {
        _showSuccess(context, 'Network Monitor je uspešno pokrenut');
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Greška prilikom pokretanja Network Monitor-a: $e');
      }
    }
  }

  Future<void> _startSecurityScanner(
    BuildContext context,
    ProcessStarter starter,
  ) async {
    try {
      await starter.startSecurityScanner(nodeId);
      if (context.mounted) {
        _showSuccess(context, 'Security Scanner je uspešno pokrenut');
      }
    } catch (e) {
      if (context.mounted) {
        _showError(
            context, 'Greška prilikom pokretanja Security Scanner-a: $e');
      }
    }
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

/// Dugme za pokretanje procesa
class _ProcessStartButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ProcessStartButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}
