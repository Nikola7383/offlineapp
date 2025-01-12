import 'package:flutter/material.dart';
import '../types/security_types.dart';

class SecurityLevelIndicator extends StatelessWidget {
  final SecurityLevel level;

  const SecurityLevelIndicator({
    super.key,
    required this.level,
  });

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
          Icon(
            _getIcon(),
            color: _getIconColor(),
            size: 20,
          ),
          const SizedBox(width: 8),
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
        return 'Nizak Rizik';
      case SecurityLevel.medium:
        return 'Srednji Rizik';
      case SecurityLevel.high:
        return 'Visok Rizik';
      case SecurityLevel.critical:
        return 'Kritičan Rizik';
    }
  }
}

class SecurityDecisionDialog extends StatefulWidget {
  final String title;
  final String description;
  final SecurityLevel securityLevel;
  final bool recommendedAction;
  final Future<bool> Function(bool decision, bool rememberChoice)
      onDecisionMade;

  const SecurityDecisionDialog({
    super.key,
    required this.title,
    required this.description,
    required this.securityLevel,
    required this.recommendedAction,
    required this.onDecisionMade,
  });

  @override
  State<SecurityDecisionDialog> createState() => _SecurityDecisionDialogState();
}

class _SecurityDecisionDialogState extends State<SecurityDecisionDialog> {
  bool _rememberChoice = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SecurityLevelIndicator(level: widget.securityLevel),
          const SizedBox(height: 16),
          Text(widget.description),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('Zapamti moju odluku'),
            value: _rememberChoice,
            onChanged: (value) {
              setState(() {
                _rememberChoice = value ?? false;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final result = await widget.onDecisionMade(false, _rememberChoice);
            if (mounted) Navigator.of(context).pop(result);
          },
          child: const Text('Odbij'),
        ),
        ElevatedButton(
          onPressed: () async {
            final result = await widget.onDecisionMade(true, _rememberChoice);
            if (mounted) Navigator.of(context).pop(result);
          },
          style: widget.recommendedAction
              ? ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                )
              : null,
          child: const Text('Dozvoli'),
        ),
      ],
    );
  }
}
