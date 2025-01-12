import 'package:injectable/injectable.dart';
import 'package:riverpod/riverpod.dart';
import '../interfaces/message_service_interface.dart';
import '../models/message.dart';
import '../models/message_types.dart';
import '../repositories/message_repository.dart';
import '../di/dependency_injection.dart';
import '../interfaces/logger_service.dart';

/// Stanje poruka
class MessagesState {
  final List<Message> messages;
  final bool isLoading;
  final String? error;

  const MessagesState({
    required this.messages,
    this.isLoading = false,
    this.error,
  });

  MessagesState copyWith({
    List<Message>? messages,
    bool? isLoading,
    String? error,
  }) {
    return MessagesState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Provider za stanje poruka
final messagesProvider =
    StateNotifierProvider<MessageController, MessagesState>((ref) {
  return MessageController(
    getIt<IMessageService>(),
    getIt<MessageRepository>(),
    getIt<ILoggerService>(),
  );
});

/// Kontroler za poruke
@injectable
class MessageController extends StateNotifier<MessagesState> {
  final IMessageService _messageService;
  final MessageRepository _messageRepository;
  final ILoggerService _logger;

  MessageController(
    this._messageService,
    this._messageRepository,
    this._logger,
  ) : super(const MessagesState(messages: [])) {
    initialize();
  }

  /// Inicijalizuje kontroler
  Future<void> initialize() async {
    try {
      state = state.copyWith(isLoading: true);
      final messages = await _messageRepository.getAllMessages();
      state = state.copyWith(
        messages: messages,
        isLoading: false,
      );
    } catch (e) {
      _logger.error('Failed to initialize MessageController', e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Šalje poruku
  Future<void> sendMessage({
    required String recipientId,
    required String content,
    required String type,
    required int priority,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      state = state.copyWith(isLoading: true);

      await _messageService.sendMessage(
        recipientId: recipientId,
        content: content,
        type: type,
        priority: priority,
      );

      final message = _messageService.createMessage(
        recipientId: recipientId,
        content: content,
        type: type,
        priority: priority,
        metadata: metadata,
      );

      await _messageRepository.saveMessage(message);

      state = state.copyWith(
        messages: [...state.messages, message],
        isLoading: false,
      );
    } catch (e) {
      _logger.error('Failed to send message', e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Briše poruku
  Future<void> deleteMessage(String id) async {
    try {
      state = state.copyWith(isLoading: true);
      await _messageRepository.deleteMessage(id);
      state = state.copyWith(
        messages: state.messages.where((m) => m.id != id).toList(),
        isLoading: false,
      );
    } catch (e) {
      _logger.error('Failed to delete message', e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Briše sve poruke
  Future<void> deleteAllMessages() async {
    try {
      state = state.copyWith(isLoading: true);
      await _messageRepository.deleteAllMessages();
      state = state.copyWith(
        messages: [],
        isLoading: false,
      );
    } catch (e) {
      _logger.error('Failed to delete all messages', e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Vraća poruke po tipu
  List<Message> getMessagesByType(String type) {
    return state.messages.where((m) => m.type == type).toList();
  }

  /// Vraća poruke po prioritetu
  List<Message> getMessagesByPriority(int priority) {
    return state.messages.where((m) => m.priority == priority).toList();
  }

  /// Vraća poruke za primaoca
  List<Message> getMessagesForRecipient(String recipientId) {
    return state.messages.where((m) => m.recipientId == recipientId).toList();
  }

  /// Vraća poruke od pošiljaoca
  List<Message> getMessagesFromSender(String senderId) {
    return state.messages.where((m) => m.senderId == senderId).toList();
  }
}
