import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/bloc/chat_bloc.dart';
import '../widgets/message_list.dart';
import '../widgets/message_input.dart';
import '../widgets/sync_indicator.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Chat'),
        actions: [
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              final isSyncing = state is ChatLoaded ? state.isSyncing : false;
              return SyncIndicator(isSyncing: isSyncing);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is ChatError) {
                    return Center(
                      child: Text(
                        'Error: ${state.message}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (state is ChatLoaded) {
                    return MessageList(messages: state.messages);
                  }

                  return const Center(
                    child: Text('Start a conversation'),
                  );
                },
              ),
            ),
            const MessageInput(),
          ],
        ),
      ),
    );
  }
}
