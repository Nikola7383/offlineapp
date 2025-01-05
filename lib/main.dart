import 'package:flutter/material.dart';
import 'services/chat_history_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatTestScreen(),
    );
  }
}

class ChatTestScreen extends StatefulWidget {
  @override
  _ChatTestScreenState createState() => _ChatTestScreenState();
}

class _ChatTestScreenState extends State<ChatTestScreen> {
  final ChatHistoryService chatService = ChatHistoryService();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    chatService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat History Test'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              await chatService.clearHistory();
              setState(() {});
            },
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              chatService.exportToFile();
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Exported to file')));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chatService.getMessages().length,
              itemBuilder: (context, index) {
                final message = chatService.getMessages()[index];
                return ListTile(
                  title: Text(message.content),
                  subtitle: Text(
                      '${message.isUser ? "User" : "AI"} - ${message.timestamp.hour}:${message.timestamp.minute}'),
                  leading: Icon(
                    message.isUser ? Icons.person : Icons.computer,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    if (_controller.text.isNotEmpty) {
                      // Simuliramo chat
                      await chatService.saveMessage(_controller.text, true);
                      await chatService.saveMessage(
                          "AI odgovor na: ${_controller.text}", false);
                      _controller.clear();
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    chatService.dispose();
    super.dispose();
  }
}
