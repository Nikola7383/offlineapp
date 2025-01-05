abstract class ErrorStrategy<T extends Exception> {
  final dynamic fallback;

  ErrorStrategy([this.fallback]);

  Future<AppError> handle(T error, StackTrace stackTrace);
}

class NetworkErrorStrategy extends ErrorStrategy<NetworkException> {
  @override
  Future<AppError> handle(NetworkException error, StackTrace stackTrace) async {
    return NetworkError(
      message: error.message,
      statusCode: error.statusCode,
      endpoint: error.endpoint,
    );
  }
}

class DatabaseErrorStrategy extends ErrorStrategy<DatabaseException> {
  @override
  Future<AppError> handle(
      DatabaseException error, StackTrace stackTrace) async {
    return DatabaseError(
      message: error.message,
      operation: error.operation,
      table: error.table,
    );
  }
}

class SecurityErrorStrategy extends ErrorStrategy<SecurityException> {
  @override
  Future<AppError> handle(
      SecurityException error, StackTrace stackTrace) async {
    return SecurityError(
      message: error.message,
      context: {'timestamp': DateTime.now().toIso8601String()},
    );
  }
}

class ValidationErrorStrategy extends ErrorStrategy<ValidationException> {
  @override
  Future<AppError> handle(
      ValidationException error, StackTrace stackTrace) async {
    return AppError(
      code: 'VALIDATION_ERROR',
      message: error.message,
      severity: ErrorSeverity.warning,
      context: {'fields': error.fields},
    );
  }
}

class DefaultErrorStrategy extends ErrorStrategy<Exception> {
  @override
  Future<AppError> handle(Exception error, StackTrace stackTrace) async {
    return AppError(
      code: 'UNKNOWN_ERROR',
      message: error.toString(),
      severity: ErrorSeverity.error,
      stackTrace: stackTrace,
    );
  }
}
