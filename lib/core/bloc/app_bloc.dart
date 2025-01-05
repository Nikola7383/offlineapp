import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../app/app_service.dart';
import '../models/message.dart';
import '../auth/auth_service.dart';
import '../logging/logger_service.dart';

// Events
abstract class AppEvent {}

class AppStarted extends AppEvent {}

class AppAuthenticated extends AppEvent {
  final User user;
  AppAuthenticated(this.user);
}

class AppLoggedOut extends AppEvent {}

class AppError extends AppEvent {
  final String message;
  AppError(this.message);
}

class MessageReceived extends AppEvent {
  final Message message;
  MessageReceived(this.message);
}

class ConnectionStatusChanged extends AppEvent {
  final bool isConnected;
  ConnectionStatusChanged(this.isConnected);
}

// States
abstract class AppState {}

class AppInitial extends AppState {}

class AppLoading extends AppState {}

class AppReady extends AppState {
  final User? user;
  final List<Message> messages;
  final bool isConnected;
  final bool isSyncing;
  final Map<String, dynamic> settings;

  AppReady({
    this.user,
    this.messages = const [],
    this.isConnected = false,
    this.isSyncing = false,
    this.settings = const {},
  });

  AppReady copyWith({
    User? user,
    List<Message>? messages,
    bool? isConnected,
    bool? isSyncing,
    Map<String, dynamic>? settings,
  }) {
    return AppReady(
      user: user ?? this.user,
      messages: messages ?? this.messages,
      isConnected: isConnected ?? this.isConnected,
      isSyncing: isSyncing ?? this.isSyncing,
      settings: settings ?? this.settings,
    );
  }
}

class AppFailure extends AppState {
  final String error;
  AppFailure(this.error);
}

class AppBloc extends Bloc<AppEvent, AppState> {
  final AppService _appService;
  final LoggerService _logger;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _connectionSubscription;

  AppBloc({
    required AppService appService,
    required LoggerService logger,
  })  : _appService = appService,
        _logger = logger,
        super(AppInitial()) {
    on<AppStarted>(_onAppStarted);
    on<AppAuthenticated>(_onAppAuthenticated);
    on<AppLoggedOut>(_onAppLoggedOut);
    on<MessageReceived>(_onMessageReceived);
    on<ConnectionStatusChanged>(_onConnectionStatusChanged);
    on<AppError>(_onAppError);
  }

  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AppState> emit,
  ) async {
    try {
      emit(AppLoading());

      // Inicijalizacija app servisa
      final initialized = await _appService.initialize();
      if (!initialized) {
        throw Exception('Failed to initialize app');
      }

      // Postavi listenere
      _setupSubscriptions();

      // Učitaj inicijalne podatke
      final messages = await _appService.getRecentMessages();
      final user = _appService.auth.currentUser;
      final settings = await _loadSettings();

      emit(AppReady(
        user: user,
        messages: messages,
        settings: settings,
      ));
    } catch (e) {
      _logger.error('Failed to start app', e);
      emit(AppFailure(e.toString()));
    }
  }

  Future<void> _onAppAuthenticated(
    AppAuthenticated event,
    Emitter<AppState> emit,
  ) async {
    if (state is AppReady) {
      final currentState = state as AppReady;
      emit(currentState.copyWith(user: event.user));

      // Učitaj poruke za novog korisnika
      final messages = await _appService.getRecentMessages();
      emit(currentState.copyWith(messages: messages));
    }
  }

  Future<void> _onAppLoggedOut(
    AppLoggedOut event,
    Emitter<AppState> emit,
  ) async {
    if (state is AppReady) {
      final currentState = state as AppReady;
      emit(currentState.copyWith(
        user: null,
        messages: [],
      ));
    }
  }

  Future<void> _onMessageReceived(
    MessageReceived event,
    Emitter<AppState> emit,
  ) async {
    if (state is AppReady) {
      final currentState = state as AppReady;
      final updatedMessages = [
        event.message,
        ...currentState.messages,
      ];
      emit(currentState.copyWith(messages: updatedMessages));
    }
  }

  void _onConnectionStatusChanged(
    ConnectionStatusChanged event,
    Emitter<AppState> emit,
  ) {
    if (state is AppReady) {
      final currentState = state as AppReady;
      emit(currentState.copyWith(isConnected: event.isConnected));
    }
  }

  void _onAppError(
    AppError event,
    Emitter<AppState> emit,
  ) {
    _logger.error('App error', event.message);
    emit(AppFailure(event.message));
  }

  void _setupSubscriptions() {
    _messageSubscription?.cancel();
    _messageSubscription = _appService.messageStream.listen(
      (message) => add(MessageReceived(message)),
      onError: (error) => add(AppError(error.toString())),
    );

    _connectionSubscription?.cancel();
    _connectionSubscription = _appService.mesh.connectionStream.listen(
      (isConnected) => add(ConnectionStatusChanged(isConnected)),
      onError: (error) => add(AppError(error.toString())),
    );
  }

  Future<Map<String, dynamic>> _loadSettings() async {
    try {
      return {
        'notifications_enabled':
            _appService.settings.getSetting<bool>('notifications_enabled') ??
                true,
        'dark_mode':
            _appService.settings.getSetting<bool>('dark_mode') ?? false,
        'sync_interval':
            _appService.settings.getSetting<int>('sync_interval_minutes') ?? 15,
      };
    } catch (e) {
      _logger.error('Failed to load settings', e);
      return {};
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();
    return super.close();
  }
}
