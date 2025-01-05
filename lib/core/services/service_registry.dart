import 'package:get_it/get_it.dart';
import '../interfaces/logger.dart';
import '../interfaces/message_handler.dart';
import '../interfaces/base_service.dart';
import 'logger_impl.dart';
import 'message_handler_impl.dart';

class ServiceRegistry {
  static final _instance = ServiceRegistry._();
  static ServiceRegistry get instance => _instance;

  final _getIt = GetIt.instance;
  bool _isInitialized = false;

  ServiceRegistry._();

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Register core services
    _getIt.registerSingleton<Logger>(LoggerImpl());

    // Register services that depend on Logger
    _getIt.registerSingletonAsync<MessageHandler>(() async {
      final handler = MessageHandlerImpl(_getIt<Logger>());
      await handler.initialize();
      return handler;
    });

    // Wait for all async registrations
    await _getIt.allReady();
    _isInitialized = true;
  }

  Future<void> dispose() async {
    if (!_isInitialized) return;

    // Dispose all services that implement BaseService
    for (final service in _getIt.allInstances<BaseService>()) {
      await service.dispose();
    }

    await _getIt.reset();
    _isInitialized = false;
  }

  T get<T extends Object>() => _getIt<T>();
}
