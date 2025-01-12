import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/master_admin/nodes_provider.dart';

class NodesScreen extends ConsumerStatefulWidget {
  const NodesScreen({super.key});

  @override
  ConsumerState<NodesScreen> createState() => _NodesScreenState();
}

class _NodesScreenState extends ConsumerState<NodesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(nodesProvider.notifier).refreshNodes());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nodesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Čvorovi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: state.isLoading
                ? null
                : () => ref.read(nodesProvider.notifier).refreshNodes(),
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
                              'Status Mreže',
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
                                  'Aktivni',
                                  state.activeNodes.toString(),
                                  Colors.green,
                                ),
                                _buildStatusIndicator(
                                  'Neaktivni',
                                  state.inactiveNodes.toString(),
                                  Colors.red,
                                ),
                                _buildStatusIndicator(
                                  'Ukupno',
                                  (state.activeNodes + state.inactiveNodes)
                                      .toString(),
                                  Colors.blue,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Lista čvorova
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
                                    'Lista Čvorova',
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
                                        child: Text('Svi'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'active',
                                        child: Text('Aktivni'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'inactive',
                                        child: Text('Neaktivni'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) {
                                        ref
                                            .read(nodesProvider.notifier)
                                            .setFilter(value);
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: state.filteredNodes.length,
                                  itemBuilder: (context, index) {
                                    final node = state.filteredNodes[index];
                                    return Card(
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: node.isActive
                                              ? Colors.green
                                              : Colors.red,
                                          child: Icon(
                                            node.isActive
                                                ? Icons.check
                                                : Icons.close,
                                            color: Colors.white,
                                          ),
                                        ),
                                        title: Text(node.name),
                                        subtitle: Text(
                                            'ID: ${node.id}\nPoslednj aktivnost: ${node.lastActivity}'),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.more_vert),
                                          onPressed: () =>
                                              _showNodeOptions(node),
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

  void _showNodeOptions(NodeInfo node) {
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
                _showNodeDetails(node);
              },
            ),
            if (!node.isActive)
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Pokušaj ponovno povezivanje'),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(nodesProvider.notifier).reconnectNode(node.id);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Ukloni čvor'),
              onTap: () {
                Navigator.pop(context);
                _confirmNodeRemoval(node);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNodeDetails(NodeInfo node) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(node.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${node.id}'),
            const SizedBox(height: 8),
            Text('Status: ${node.isActive ? 'Aktivan' : 'Neaktivan'}'),
            const SizedBox(height: 8),
            Text('Poslednja aktivnost: ${node.lastActivity}'),
            const SizedBox(height: 8),
            Text('Broj poruka: ${node.messageCount}'),
            const SizedBox(height: 8),
            Text('Uptime: ${(node.uptime * 100).toInt()}%'),
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

  Future<void> _confirmNodeRemoval(NodeInfo node) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Potvrda'),
        content: Text(
            'Da li ste sigurni da želite da uklonite čvor "${node.name}"?'),
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
      await ref.read(nodesProvider.notifier).removeNode(node.id);
    }
  }
}
