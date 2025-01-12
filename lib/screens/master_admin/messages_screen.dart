import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/master_admin/messages_provider.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(messagesProvider.notifier).refreshMessages());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Poruke'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: state.isLoading
                ? null
                : () => ref.read(messagesProvider.notifier).refreshMessages(),
          ),
        ],
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status sekcija
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Status Poruka',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatusIndicator(
                                  'Isporučene',
                                  state.deliveredMessages.toString(),
                                  Colors.green,
                                ),
                                _buildStatusIndicator(
                                  'Na čekanju',
                                  state.pendingMessages.toString(),
                                  Colors.orange,
                                ),
                                _buildStatusIndicator(
                                  'Neuspešne',
                                  state.failedMessages.toString(),
                                  Colors.red,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Lista poruka
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Lista Poruka',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  DropdownButton<String>(
                                    value: state.filter,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'all',
                                        child: Text('Sve'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'delivered',
                                        child: Text('Isporučene'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'pending',
                                        child: Text('Na čekanju'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'failed',
                                        child: Text('Neuspešne'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) {
                                        ref
                                            .read(messagesProvider.notifier)
                                            .setFilter(value);
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: state.filteredMessages.length,
                                  itemBuilder: (context, index) {
                                    final message =
                                        state.filteredMessages[index];
                                    return Card(
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor:
                                              _getStatusColor(message.status),
                                          child: Icon(
                                            _getStatusIcon(message.status),
                                            color: Colors.white,
                                          ),
                                        ),
                                        title: Text(message.subject),
                                        subtitle: Text(
                                            'Od: ${message.sender}\nZa: ${message.recipient}\nVreme: ${message.timestamp}'),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.more_vert),
                                          onPressed: () =>
                                              _showMessageOptions(message),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatusIndicator(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'delivered':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'delivered':
        return Icons.check;
      case 'pending':
        return Icons.schedule;
      case 'failed':
        return Icons.error_outline;
      default:
        return Icons.help_outline;
    }
  }

  void _showMessageOptions(MessageInfo message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Detalji'),
              onTap: () {
                Navigator.pop(context);
                _showMessageDetails(message);
              },
            ),
            if (message.status == 'failed')
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Pokušaj ponovno slanje'),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(messagesProvider.notifier).retryMessage(message.id);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Ukloni poruku'),
              onTap: () {
                Navigator.pop(context);
                _confirmMessageRemoval(message);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMessageDetails(MessageInfo message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message.subject),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${message.id}'),
            const SizedBox(height: 8),
            Text('Od: ${message.sender}'),
            const SizedBox(height: 8),
            Text('Za: ${message.recipient}'),
            const SizedBox(height: 8),
            Text('Status: ${_getStatusText(message.status)}'),
            const SizedBox(height: 8),
            Text('Vreme: ${message.timestamp}'),
            const SizedBox(height: 8),
            Text('Veličina: ${message.size} bytes'),
            if (message.error != null) ...[
              const SizedBox(height: 8),
              Text('Greška: ${message.error}',
                  style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Zatvori'),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'delivered':
        return 'Isporučena';
      case 'pending':
        return 'Na čekanju';
      case 'failed':
        return 'Neuspešna';
      default:
        return 'Nepoznato';
    }
  }

  Future<void> _confirmMessageRemoval(MessageInfo message) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Potvrda'),
        content: Text(
            'Da li ste sigurni da želite da uklonite poruku "${message.subject}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Odustani'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Potvrdi'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(messagesProvider.notifier).removeMessage(message.id);
    }
  }
}
