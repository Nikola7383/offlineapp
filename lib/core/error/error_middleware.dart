import 'dart:async';
import 'package:flutter/foundation.dart';
import '../logging/logger_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ErrorMiddleware extends BlocObserver {
  final LoggerService _logger;
  final void Function(String)? onFatalError;
  final void Function(String)? onUserError;

  ErrorMiddleware({
    required LoggerService logger,
    this.onFatalError,
    this.onUserError,
  }) : _logger = logger;

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    _handleError(error, stackTrace);
    super.onError(bloc, error, stackTrace);
  }

  void _handleError(Object error, StackTrace stackTrace) {
    if (error is AppException) {
      _handleAppException(error);
    } else {
      _handleSystemError(error, stackTrace);
    }
  }

  void _handleAppException(AppException exception) {
    switch (exception.severity) {
      case ErrorSeverity.fatal:
        _logger.error(
          'Fatal Error: ${exception.message}',
          exception,
        );
        onFatalError?.call(exception.userMessage);
        break;

      case ErrorSeverity.error:
        _logger.error(
          'Error: ${exception.message}',
          exception,
        );
        onUserError?.call(exception.userMessage);
        break;

      case ErrorSeverity.warning:
        _logger.warning(
          'Warning: ${exception.message}',
          exception,
        );
        onUserError?.call(exception.userMessage);
        break;
    }
  }

  void _handleSystemError(Object error, StackTrace stackTrace) {
    _logger.error(
      'System Error',
      error,
      stackTrace,
    );

    if (kDebugMode) {
      // U debug modu prikaži kompletan stack trace
      onFatalError?.call('$error\n$stackTrace');
    } else {
      // U produkciji prikaži generičku poruku
      onFatalError?.call('An unexpected error occurred');
    }
  }

  Future<T> runGuarded<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e, stackTrace) {
      _handleError(e, stackTrace);
      rethrow;
    }
  }

  T runGuardedSync<T>(T Function() action) {
    try {
      return action();
    } catch (e, stackTrace) {
      _handleError(e, stackTrace);
      rethrow;
    }
  }
}

class AppException implements Exception {
  final String message;
  final String userMessage;
  final ErrorSeverity severity;
  final String? code;
  final Map<String, dynamic>? details;

  AppException({
    required this.message,
    String? userMessage,
    this.severity = ErrorSeverity.error,
    this.code,
    this.details,
  }) : userMessage = userMessage ?? message;

  @override
  String toString() => 'AppException: $message (Code: $code)';
}

enum ErrorSeverity {
  fatal, // Aplikacija ne može da nastavi sa radom
  error, // Ozbiljna greška ali aplikacija može da nastavi
  warning, // Manje greške koje ne utiču na glavni tok
}
