import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/message.dart';
import '../messaging/message_service.dart';
import '../sync/sync_service.dart';
import '../storage/database_service.dart';
import '../logging/logger_service.dart';

// Events
abstract class ChatEvent {}

class SendMessageEvent extends ChatEvent {
  final String content;
  final String senderId;
  SendMessageEvent(this.content, this.senderId);
}

class LoadMessagesEvent extends ChatEvent {
  final int limit;
  LoadMessagesEvent({this.limit = 50});
}

class SyncRequestEvent extends ChatEvent {}

// States
abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<Message> messages;
  final bool isSyncing;

  ChatLoaded({
    required this.messages,
    this.isSyncing = false,
  });
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}

// BLoC
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final MessageService messageService;
  final SyncService syncService;
  final DatabaseService storage;
  final LoggerService logger;

  Timer? _syncTimer;

  ChatBloc({
    required this.messageService,
    required this.syncService,
    required this.storage,
    required this.logger,
  }) : super(ChatInitial()) {
    on<SendMessageEvent>(_handleSendMessage);
    on<LoadMessagesEvent>(_handleLoadMessages);
    on<SyncRequestEvent>(_handleSync);

    // Započni periodičnu sinhronizaciju
    _startPeriodicSync();
  }

  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => add(SyncRequestEvent()),
    );
  }

  Future<void> _handleSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final message = Message(
        id: DateTime.now().toIso8601String(),
        content: event.content,
        senderId: event.senderId,
        timestamp: DateTime.now(),
      );

      await messageService.sendMessage(message);

      // Ažuriraj UI sa novom porukom
      if (state is ChatLoaded) {
        final currentMessages = (state as ChatLoaded).messages;
        emit(ChatLoaded(
          messages: [message, ...currentMessages],
          isSyncing: false,
        ));
      }

      // Pokreni sinhronizaciju
      add(SyncRequestEvent());
    } catch (e) {
      logger.error('Failed to send message', e);
      emit(ChatError('Failed to send message: ${e.toString()}'));
    }
  }

  Future<void> _handleLoadMessages(
    LoadMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(ChatLoading());

      final messages = await storage.getMessages(
        limit: event.limit,
      );

      emit(ChatLoaded(messages: messages));
    } catch (e) {
      logger.error('Failed to load messages', e);
      emit(ChatError('Failed to load messages: ${e.toString()}'));
    }
  }

  Future<void> _handleSync(
    SyncRequestEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      if (state is ChatLoaded) {
        emit(ChatLoaded(
          messages: (state as ChatLoaded).messages,
          isSyncing: true,
        ));
      }

      final result = await syncService.synchronize();

      if (result.success) {
        // Učitaj ažurirane poruke
        add(LoadMessagesEvent());
      } else {
        logger.warning('Sync failed: ${result.reason}');
      }
    } catch (e) {
      logger.error('Sync error', e);
      emit(ChatError('Sync failed: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _syncTimer?.cancel();
    return super.close();
  }
}
