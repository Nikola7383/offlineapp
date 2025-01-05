import 'package:flutter/material.dart';
import '../../core/models/message.dart';

class MessageTile extends StatelessWidget {
  final Message message;
  final VoidCallback? onTap;

  const MessageTile({
    super.key,
    required this.message,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(message.content),
      subtitle: Text(
        _formatTimestamp(message.timestamp),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: _buildStatusIcon(),
      onTap: onTap,
    );
  }

  Widget _buildStatusIcon() {
    switch (message.status) {
      case MessageStatus.pending:
        return const Icon(Icons.pending, color: Colors.orange);
      case MessageStatus.sending:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case MessageStatus.sent:
        return const Icon(Icons.check_circle, color: Colors.green);
      case MessageStatus.delivered:
        return const Icon(Icons.done_all, color: Colors.blue);
      case MessageStatus.failed:
        return const Icon(Icons.error, color: Colors.red);
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
