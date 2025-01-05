import 'package:flutter/material.dart';
import '../../core/models/message.dart';
import '../../core/services/service_helper.dart';
import 'message_tile.dart';

class MessageList extends StatefulWidget {
  const MessageList({super.key});

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final _scrollController = ScrollController();
  bool _isLoading = false;
  List<Message> _messages = [];
  int _currentPage = 0;
  static const _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final result = await Services.storage.getMessages(
        limit: _pageSize,
        offset: _currentPage * _pageSize,
      );

      if (result.isSuccess) {
        setState(() {
          _messages.addAll(result.data!);
          _currentPage++;
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _messages.clear();
          _currentPage = 0;
        });
        await _loadMessages();
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _messages.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _messages.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          return MessageTile(
            message: _messages[index],
            onTap: () => _showMessageDetails(context, _messages[index]),
          );
        },
      ),
    );
  }

  void _showMessageDetails(BuildContext context, Message message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => MessageDetailsSheet(message: message),
    );
  }
}

class MessageDetailsSheet extends StatelessWidget {
  final Message message;

  const MessageDetailsSheet({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Message Details',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _DetailRow('Status:', message.status.name),
          _DetailRow('Sent:', message.timestamp.toString()),
          _DetailRow('ID:', message.id),
          _DetailRow('Sender:', message.senderId),
          const SizedBox(height: 16),
          Text(
            message.content,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }
}
