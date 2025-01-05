import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/bloc/auth_bloc.dart';
import 'package:secure_event_app/core/auth/auth_service.dart';
import 'package:secure_event_app/core/app/app_service.dart';
import 'package:secure_event_app/core/logging/logger_service.dart';

class MockAuthService extends Mock implements AuthService {}

class MockAppService extends Mock implements AppService {}

class MockLoggerService extends Mock implements LoggerService {}

void main() {
  late AuthBloc authBloc;
  late MockAuthService mockAuthService;
  late MockAppService mockAppService;
  late MockLoggerService mockLogger;

  setUp(() {
    mockAuthService = MockAuthService();
    mockAppService = MockAppService();
    mockLogger = MockLoggerService();

    authBloc = AuthBloc(
      authService: mockAuthService,
      appService: mockAppService,
      logger: mockLogger,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc Tests', () {
    final testUser = User(
      id: 'test_id',
      username: 'test',
      email: 'test@example.com',
      publicKey: 'key',
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when login is successful',
      build: () {
        when(mockAuthService.login(any, any)).thenAnswer(
          (_) async => AuthResult(success: true, user: testUser),
        );
        when(mockAppService.initialize()).thenAnswer((_) async => true);
        return authBloc;
      },
      act: (bloc) => bloc.add(LoginRequested(
        username: 'test',
        password: 'password',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login fails',
      build: () {
        when(mockAuthService.login(any, any)).thenAnswer(
          (_) async => AuthResult(
            success: false,
            error: 'Invalid credentials',
          ),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(LoginRequested(
        username: 'wrong',
        password: 'wrong',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when logout is successful',
      build: () {
        when(mockAuthService.logout()).thenAnswer((_) async => true);
        return authBloc;
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthUnauthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'handles auth check correctly when user is authenticated',
      build: () {
        when(mockAuthService.initialize()).thenAnswer((_) async => true);
        when(mockAuthService.currentUser).thenReturn(testUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
      ],
    );
  });
}
