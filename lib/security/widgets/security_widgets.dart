import 'package:flutter/material.dart';
import '../types/security_types.dart';

/// Widget za prikaz nivoa sigurnosti
class SecurityLevelIndicator extends StatelessWidget {
  final SecurityLevel level;

  const SecurityLevelIndicator({required this.level, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIcon(), color: _getIconColor()),
          const SizedBox(width: 8.0),
          Text(
            _getLevelText(),
            style: TextStyle(
              color: _getIconColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (level) {
      case SecurityLevel.low:
        return Colors.green.withOpacity(0.1);
      case SecurityLevel.medium:
        return Colors.orange.withOpacity(0.1);
      case SecurityLevel.high:
        return Colors.red.withOpacity(0.1);
      case SecurityLevel.critical:
        return Colors.purple.withOpacity(0.1);
    }
  }

  Color _getIconColor() {
    switch (level) {
      case SecurityLevel.low:
        return Colors.green;
      case SecurityLevel.medium:
        return Colors.orange;
      case SecurityLevel.high:
        return Colors.red;
      case SecurityLevel.critical:
        return Colors.purple;
    }
  }

  IconData _getIcon() {
    switch (level) {
      case SecurityLevel.low:
        return Icons.check_circle;
      case SecurityLevel.medium:
        return Icons.warning;
      case SecurityLevel.high:
        return Icons.error;
      case SecurityLevel.critical:
        return Icons.dangerous;
    }
  }

  String _getLevelText() {
    switch (level) {
      case SecurityLevel.low:
        return 'Nizak rizik';
      case SecurityLevel.medium:
        return 'Srednji rizik';
      case SecurityLevel.high:
        return 'Visok rizik';
      case SecurityLevel.critical:
        return 'Kritičan rizik';
    }
  }
}

/// Dialog za sigurnosne odluke
class SecurityDecisionDialog extends StatelessWidget {
  final String title;
  final String description;
  final SecurityLevel securityLevel;
  final bool recommendedAction;

  const SecurityDecisionDialog(
      {required this.title,
      required this.description,
      required this.securityLevel,
      required this.recommendedAction,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(description),
          const SizedBox(height: 16),
          SecurityLevelIndicator(level: securityLevel),
          if (recommendedAction) ...[
            const SizedBox(height: 8),
            const Text(
              'Preporučena akcija: Dozvoli',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Odbij'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: recommendedAction ? Colors.green : null,
          ),
          child: const Text('Dozvoli'),
        ),
      ],
    );
  }
}
