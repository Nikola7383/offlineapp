import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/bloc/app_bloc.dart';
import 'package:secure_event_app/core/app/app_service.dart';
import 'package:secure_event_app/core/models/message.dart';
import 'package:secure_event_app/core/auth/auth_service.dart';

class MockAppService extends Mock implements AppService {}

class MockLoggerService extends Mock implements LoggerService {}

void main() {
  late AppBloc appBloc;
  late MockAppService mockAppService;
  late MockLoggerService mockLogger;

  setUp(() {
    mockAppService = MockAppService();
    mockLogger = MockLoggerService();

    // Setup default mock responses
    when(mockAppService.initialize()).thenAnswer((_) async => true);
    when(mockAppService.getRecentMessages()).thenAnswer((_) async => []);
    when(mockAppService.messageStream)
        .thenAnswer((_) => Stream<Message>.empty());
    when(mockAppService.mesh.connectionStream)
        .thenAnswer((_) => Stream<bool>.empty());

    appBloc = AppBloc(
      appService: mockAppService,
      logger: mockLogger,
    );
  });

  tearDown(() {
    appBloc.close();
  });

  group('AppBloc Tests', () {
    blocTest<AppBloc, AppState>(
      'emits [AppLoading, AppReady] when AppStarted is added',
      build: () => appBloc,
      act: (bloc) => bloc.add(AppStarted()),
      expect: () => [
        isA<AppLoading>(),
        isA<AppReady>(),
      ],
    );

    blocTest<AppBloc, AppState>(
      'updates state when user authenticates',
      build: () => appBloc,
      seed: () => AppReady(),
      act: (bloc) => bloc.add(AppAuthenticated(
        User(
          id: 'test_id',
          username: 'test',
          email: 'test@example.com',
          publicKey: 'key',
        ),
      )),
      expect: () => [
        isA<AppReady>().having(
          (state) => state.user?.username,
          'username',
          equals('test'),
        ),
      ],
    );

    blocTest<AppBloc, AppState>(
      'handles new messages',
      build: () => appBloc,
      seed: () => AppReady(messages: []),
      act: (bloc) => bloc.add(MessageReceived(
        Message(
          id: '1',
          content: 'Test message',
          senderId: 'user1',
          timestamp: DateTime.now(),
        ),
      )),
      expect: () => [
        isA<AppReady>().having(
          (state) => state.messages.length,
          'messages length',
          equals(1),
        ),
      ],
    );

    blocTest<AppBloc, AppState>(
      'handles connection status changes',
      build: () => appBloc,
      seed: () => AppReady(isConnected: false),
      act: (bloc) => bloc.add(ConnectionStatusChanged(true)),
      expect: () => [
        isA<AppReady>().having(
          (state) => state.isConnected,
          'connection status',
          isTrue,
        ),
      ],
    );
  });
}
