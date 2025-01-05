import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth/auth_service.dart';
import '../logging/logger_service.dart';
import '../app/app_service.dart';

// Events
abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;

  LoginRequested({
    required this.username,
    required this.password,
  });
}

class LogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class BiometricLoginRequested extends AuthEvent {}

// States
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final AppService _appService;
  final LoggerService _logger;

  AuthBloc({
    required AuthService authService,
    required AppService appService,
    required LoggerService logger,
  })  : _authService = authService,
        _appService = appService,
        _logger = logger,
        super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<BiometricLoginRequested>(_onBiometricLoginRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      final result = await _authService.login(
        event.username,
        event.password,
      );

      if (result.success && result.user != null) {
        // Sačuvaj kredencijale za biometrijsku autentikaciju
        await _authService.saveCredentials(
          username: event.username,
          password: event.password,
        );

        // Inicijalizuj servise koji zahtevaju autentikaciju
        await _appService.initialize();

        emit(AuthAuthenticated(result.user!));
      } else {
        emit(AuthError(result.error ?? 'Authentication failed'));
      }
    } catch (e) {
      _logger.error('Login failed', e);
      emit(AuthError('Login failed: ${e.toString()}'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      final success = await _authService.logout();
      if (success) {
        // Očisti lokalne podatke
        await _appService.storage.clear();
        await _appService.settings.clear();

        emit(AuthUnauthenticated());
      } else {
        emit(AuthError('Logout failed'));
      }
    } catch (e) {
      _logger.error('Logout failed', e);
      emit(AuthError('Logout failed: ${e.toString()}'));
    }
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      final isInitialized = await _authService.initialize();
      if (!isInitialized) {
        emit(AuthUnauthenticated());
        return;
      }

      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        emit(AuthAuthenticated(currentUser));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      _logger.error('Auth check failed', e);
      emit(AuthError('Auth check failed: ${e.toString()}'));
    }
  }

  Future<void> _onBiometricLoginRequested(
    BiometricLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      final credentials = await _authService.getBiometricCredentials();
      if (credentials == null) {
        emit(AuthError('No saved credentials found'));
        return;
      }

      final result = await _authService.login(
        credentials.username,
        credentials.password,
      );

      if (result.success && result.user != null) {
        await _appService.initialize();
        emit(AuthAuthenticated(result.user!));
      } else {
        emit(AuthError(result.error ?? 'Biometric authentication failed'));
      }
    } catch (e) {
      _logger.error('Biometric login failed', e);
      emit(AuthError('Biometric login failed: ${e.toString()}'));
    }
  }
}
