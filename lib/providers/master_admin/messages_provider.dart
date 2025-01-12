import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'messages_provider.freezed.dart';

@freezed
class MessageInfo with _$MessageInfo {
  const factory MessageInfo({
    required String id,
    required String subject,
    required String sender,
    required String recipient,
    required String status,
    required String timestamp,
    required int size,
    String? error,
  }) = _MessageInfo;
}

@freezed
class MessagesState with _$MessagesState {
  const factory MessagesState({
    @Default([]) List<MessageInfo> messages,
    @Default('all') String filter,
    @Default(false) bool isLoading,
    String? error,
  }) = _MessagesState;

  const MessagesState._();

  List<MessageInfo> get filteredMessages {
    switch (filter) {
      case 'delivered':
        return messages
            .where((message) => message.status == 'delivered')
            .toList();
      case 'pending':
        return messages
            .where((message) => message.status == 'pending')
            .toList();
      case 'failed':
        return messages.where((message) => message.status == 'failed').toList();
      default:
        return messages;
    }
  }

  int get deliveredMessages =>
      messages.where((message) => message.status == 'delivered').length;
  int get pendingMessages =>
      messages.where((message) => message.status == 'pending').length;
  int get failedMessages =>
      messages.where((message) => message.status == 'failed').length;
}

class MessagesNotifier extends StateNotifier<MessagesState> {
  MessagesNotifier() : super(const MessagesState()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      // TODO: Implementirati učitavanje podataka
      await Future.delayed(const Duration(seconds: 1)); // Simulacija

      state = state.copyWith(
        isLoading: false,
        messages: [
          const MessageInfo(
            id: '1',
            subject: 'Važno obaveštenje',
            sender: 'Petar Petrović',
            recipient: 'Marko Marković',
            status: 'delivered',
            timestamp: '2024-01-15 14:30',
            size: 1024,
          ),
          const MessageInfo(
            id: '2',
            subject: 'Hitna poruka',
            sender: 'Marko Marković',
            recipient: 'Jovan Jovanović',
            status: 'pending',
            timestamp: '2024-01-15 14:25',
            size: 512,
          ),
          const MessageInfo(
            id: '3',
            subject: 'Problem sa mrežom',
            sender: 'Jovan Jovanović',
            recipient: 'Petar Petrović',
            status: 'failed',
            timestamp: '2024-01-15 10:15',
            size: 2048,
            error: 'Mrežna konekcija nije dostupna',
          ),
        ],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshMessages() async {
    await _loadInitialData();
  }

  void setFilter(String filter) {
    state = state.copyWith(filter: filter);
  }

  Future<void> retryMessage(String messageId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      // TODO: Implementirati ponovno slanje poruke
      await Future.delayed(const Duration(seconds: 1)); // Simulacija

      final updatedMessages = state.messages.map((message) {
        if (message.id == messageId) {
          return message.copyWith(
            status: 'pending',
            error: null,
          );
        }
        return message;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        messages: updatedMessages,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> removeMessage(String messageId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      // TODO: Implementirati uklanjanje poruke
      await Future.delayed(const Duration(seconds: 1)); // Simulacija

      final updatedMessages =
          state.messages.where((message) => message.id != messageId).toList();

      state = state.copyWith(
        isLoading: false,
        messages: updatedMessages,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final messagesProvider =
    StateNotifierProvider<MessagesNotifier, MessagesState>((ref) {
  return MessagesNotifier();
});
