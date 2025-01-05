import 'dart:async';
import '../services/logger_service.dart';
import 'package:injectable/injectable.dart';

@injectable
class ErrorHandler extends InjectableService {
  final Map<Type, ErrorStrategy> _strategies = {};
  final _errorSubject = BehaviorSubject<AppError>();

  Stream<AppError> get errorStream => _errorSubject.stream;

  ErrorHandler(LoggerService logger) : super(logger) {
    _registerDefaultStrategies();
  }

  void registerStrategy<T extends Exception>(ErrorStrategy<T> strategy) {
    _strategies[T] = strategy;
  }

  Future<T> handleError<T>(
    Future<T> Function() operation, {
    bool shouldRethrow = false,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      final strategy = _findStrategy(error);
      final appError = await strategy.handle(error, stackTrace);

      _errorSubject.add(appError);
      logger.error(
        appError.message,
        error,
        stackTrace,
        extras: appError.context,
      );

      if (shouldRethrow) {
        throw appError;
      }

      return strategy.fallback as T;
    }
  }

  ErrorStrategy _findStrategy(dynamic error) {
    return _strategies[error.runtimeType] ?? _strategies[Exception]!;
  }

  void _registerDefaultStrategies() {
    registerStrategy(NetworkErrorStrategy());
    registerStrategy(DatabaseErrorStrategy());
    registerStrategy(SecurityErrorStrategy());
    registerStrategy(ValidationErrorStrategy());
    registerStrategy(DefaultErrorStrategy());
  }

  @override
  Future<void> dispose() async {
    await _errorSubject.close();
    await super.dispose();
  }
}
