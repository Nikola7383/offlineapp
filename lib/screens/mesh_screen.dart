import 'package:flutter/material.dart';
import '../mesh/mesh_network.dart';
import '../mesh/models/node.dart';

class MeshScreen extends StatefulWidget {
  @override
  _MeshScreenState createState() => _MeshScreenState();
}

class _MeshScreenState extends State<MeshScreen> {
  late MeshNetwork _meshNetwork;
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    _initializeMeshNetwork();
  }

  Future<void> _initializeMeshNetwork() async {
    _meshNetwork = MeshNetwork();

    // Slušaj dolazne poruke
    _meshNetwork.dataStream.listen((data) {
      setState(() {
        _messages.add('Primljeno: ${String.fromCharCodes(data)}');
      });
    });

    // Pokreni mrežu
    await _meshNetwork.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mesh Network Demo'),
        actions: [
          StreamBuilder<Set<Node>>(
            stream: _meshNetwork.nodesStream,
            builder: (context, snapshot) {
              final count = snapshot.data?.length ?? 0;
              return Chip(
                label: Text('$count uređaja'),
                backgroundColor: count > 0 ? Colors.green : Colors.grey,
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _meshNetwork.start(), // Pokreće novo skeniranje
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<Set<Node>>(
              stream: _meshNetwork.nodesStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final nodes = snapshot.data!;
                if (nodes.isEmpty) {
                  return Center(
                    child: Text('Nema pronađenih uređaja'),
                  );
                }

                return ListView.builder(
                  itemCount: nodes.length,
                  itemBuilder: (context, index) {
                    final node = nodes.elementAt(index);
                    return ListTile(
                      leading: Icon(Icons.device_hub),
                      title: Text('Uređaj: ${node.id}'),
                      subtitle: Text(
                          'Baterija: ${(node.batteryLevel * 100).round()}% | '
                          'Signal: ${(node.signalStrength * 100).round()}%'),
                      trailing: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () => _sendToNode(node),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Unesite poruku...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _broadcast,
                  child: Text('Pošalji svima'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendToNode(Node node) async {
    if (_messageController.text.isEmpty) return;

    final message = _messageController.text;
    final success = await _meshNetwork.sendTo(
      node.id,
      message.codeUnits,
    );

    setState(() {
      _messages.add(success
          ? 'Poslato -> ${node.id}: $message'
          : 'Greška slanja -> ${node.id}: $message');
    });

    _messageController.clear();
  }

  void _broadcast() async {
    if (_messageController.text.isEmpty) return;

    final message = _messageController.text;
    await _meshNetwork.broadcast(message.codeUnits);

    setState(() {
      _messages.add('Broadcast: $message');
    });

    _messageController.clear();
  }

  @override
  void dispose() {
    _meshNetwork.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
