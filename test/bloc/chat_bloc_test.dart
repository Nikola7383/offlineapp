import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/bloc/chat_bloc.dart';
import 'package:secure_event_app/core/models/message.dart';

class MockMessageService extends Mock implements MessageService {}

class MockSyncService extends Mock implements SyncService {}

class MockDatabaseService extends Mock implements DatabaseService {}

class MockLoggerService extends Mock implements LoggerService {}

void main() {
  late ChatBloc chatBloc;
  late MockMessageService mockMessageService;
  late MockSyncService mockSyncService;
  late MockDatabaseService mockStorage;
  late MockLoggerService mockLogger;

  setUp(() {
    mockMessageService = MockMessageService();
    mockSyncService = MockSyncService();
    mockStorage = MockDatabaseService();
    mockLogger = MockLoggerService();

    chatBloc = ChatBloc(
      messageService: mockMessageService,
      syncService: mockSyncService,
      storage: mockStorage,
      logger: mockLogger,
    );
  });

  tearDown(() {
    chatBloc.close();
  });

  group('ChatBloc Tests', () {
    blocTest<ChatBloc, ChatState>(
      'emits [ChatLoading, ChatLoaded] when LoadMessagesEvent is added',
      build: () {
        when(mockStorage.getMessages(limit: anyNamed('limit')))
            .thenAnswer((_) async => []);
        return chatBloc;
      },
      act: (bloc) => bloc.add(LoadMessagesEvent()),
      expect: () => [
        isA<ChatLoading>(),
        isA<ChatLoaded>(),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'emits [ChatLoaded] with new message when SendMessageEvent is added',
      build: () {
        when(mockMessageService.sendMessage(any)).thenAnswer((_) async => true);
        when(mockSyncService.synchronize())
            .thenAnswer((_) async => SyncResult(success: true));
        return chatBloc;
      },
      seed: () => ChatLoaded(messages: []),
      act: (bloc) => bloc.add(SendMessageEvent('Test message', 'user1')),
      expect: () => [
        isA<ChatLoaded>(),
      ],
      verify: (_) {
        verify(mockMessageService.sendMessage(any)).called(1);
        verify(mockSyncService.synchronize()).called(1);
      },
    );

    blocTest<ChatBloc, ChatState>(
      'emits [ChatError] when message sending fails',
      build: () {
        when(mockMessageService.sendMessage(any))
            .thenThrow(Exception('Network error'));
        return chatBloc;
      },
      act: (bloc) => bloc.add(SendMessageEvent('Test message', 'user1')),
      expect: () => [
        isA<ChatError>(),
      ],
    );
  });
}
