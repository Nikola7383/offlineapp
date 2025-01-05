import 'package:flutter/material.dart';
import '../widgets/offline_indicator.dart';
import '../widgets/message_list.dart';
import '../widgets/compose_message.dart';
import '../../core/services/service_helper.dart';
import '../screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Event App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => Services.sync.sync(),
          ),
          const SyncStatusBadge(),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineIndicator(),
          Expanded(
            child: Stack(
              children: [
                const MessageList(),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      _buildSyncingIndicator(),
                      const ComposeMessage(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncingIndicator() {
    return StreamBuilder<SyncStatus>(
      stream: _getSyncStatusStream(),
      builder: (context, snapshot) {
        if (snapshot.data != SyncStatus.syncing) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(8),
          color: Colors.blue.withOpacity(0.1),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text('Syncing messages...'),
            ],
          ),
        );
      },
    );
  }

  Stream<SyncStatus> _getSyncStatusStream() async* {
    while (true) {
      yield Services.sync.status;
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
}

  // Mock data za testiranje
  final List<Room> rooms = [
    Room(
      id: '1',
      number: 1,
      lastMessage: 'Poslednja poruka...',
      lastActivity: DateTime.now(),
    ),
    Room(
      id: '2',
      number: 2,
      lastMessage: 'Test poruka...',
      lastActivity: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    print('HomeScreen building');
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Glasnik',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: AppTheme.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          final room = rooms[index];
          return ChatListItem(
            name: 'Glasnik #${room.number}',
            lastMessage: room.lastMessage,
            icon: Icons.forum,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }
}
