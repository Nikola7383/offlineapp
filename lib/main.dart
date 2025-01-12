import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/di/dependency_injection.dart';
import 'core/controllers/message_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure Event App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesState = ref.watch(messagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Event App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              ref.read(messagesProvider.notifier).deleteAllMessages();
            },
          ),
        ],
      ),
      body: messagesState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : messagesState.error != null
              ? Center(child: Text('Error: ${messagesState.error}'))
              : messagesState.messages.isEmpty
                  ? const Center(child: Text('No messages'))
                  : ListView.builder(
                      itemCount: messagesState.messages.length,
                      itemBuilder: (context, index) {
                        final message = messagesState.messages[index];
                        return ListTile(
                          title: Text(message.content),
                          subtitle: Text(
                            'From: ${message.senderId}\nTo: ${message.recipientId}',
                          ),
                          trailing: Text(
                            message.timestamp.toLocal().toString(),
                          ),
                          onTap: () {
                            // TODO: Implementirati prikaz detalja poruke
                          },
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implementirati slanje nove poruke
        },
        child: const Icon(Icons.send),
      ),
    );
  }
}
