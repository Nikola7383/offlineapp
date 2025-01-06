class ChatHistoryScreen extends StatelessWidget {
  final ChatHistoryManager _historyManager;

  const ChatHistoryScreen(this._historyManager, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.backup),
            onPressed: () async {
              try {
                await _historyManager.backupAllHistory();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('History backed up successfully')));
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Backup failed: $e')));
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: _historyManager.listSessions(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final sessions = snapshot.data!;
          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final sessionId = sessions[index];
              return FutureBuilder<List<ChatMessage>>(
                future: _historyManager.loadChat(sessionId),
                builder: (context, messageSnapshot) {
                  if (!messageSnapshot.hasData) {
                    return const ListTile(
                      title: LinearProgressIndicator(),
                    );
                  }

                  final messages = messageSnapshot.data!;
                  return ExpansionTile(
                    title: Text('Session $sessionId'),
                    subtitle: Text('${messages.length} messages'),
                    children: messages
                        .map((msg) => ListTile(
                              title: Text(msg.content),
                              subtitle: Text(msg.timestamp.toString()),
                            ))
                        .toList(),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
