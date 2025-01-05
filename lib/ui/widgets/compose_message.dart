import 'package:flutter/material.dart';
import '../../core/models/message.dart';
import '../../core/services/service_helper.dart';

class ComposeMessage extends StatefulWidget {
  const ComposeMessage({super.key});

  @override
  State<ComposeMessage> createState() => _ComposeMessageState();
}

class _ComposeMessageState extends State<ComposeMessage> {
  final _controller = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSending = true);

    try {
      final message = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        senderId: 'current_user', // TODO: Get from auth service
        timestamp: DateTime.now(),
      );

      // Prvo sačuvamo lokalno
      await Services.storage.saveMessage(message);

      // Dodamo u sync queue
      await Services.sync.queueMessage(message);

      // Ako smo online, pokušamo odmah da sinhronizujemo
      if (Services.connection.currentStatus.isConnected) {
        await Services.sync.sync();
      }

      _controller.clear();
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              enabled: !_isSending,
            ),
          ),
          const SizedBox(width: 8),
          _isSending
              ? const CircularProgressIndicator()
              : IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
        ],
      ),
    );
  }
}
