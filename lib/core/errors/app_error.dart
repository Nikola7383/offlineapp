abstract class AppError implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppError(this.message, [this.originalError, this.stackTrace]);

  @override
  String toString() {
    if (originalError != null) {
      return '$message (Original error: $originalError)';
    }
    return message;
  }
}

class NetworkError extends AppError {
  const NetworkError(String message,
      [dynamic originalError, StackTrace? stackTrace])
      : super(message, originalError, stackTrace);
}

class DatabaseError extends AppError {
  const DatabaseError(String message,
      [dynamic originalError, StackTrace? stackTrace])
      : super(message, originalError, stackTrace);
}

class ValidationError extends AppError {
  const ValidationError(String message,
      [dynamic originalError, StackTrace? stackTrace])
      : super(message, originalError, stackTrace);
}
