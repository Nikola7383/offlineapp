/// Base klasa za greške u servisima
abstract class ServiceError implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const ServiceError(this.message, [this.originalError, this.stackTrace]);

  @override
  String toString() {
    if (originalError != null) {
      return '$message (Original error: $originalError)';
    }
    return message;
  }
}

/// Greška pri mrežnim operacijama
class NetworkError extends ServiceError {
  const NetworkError(String message, [dynamic original, StackTrace? stackTrace])
      : super(message, original, stackTrace);
}

/// Greška pri storage operacijama
class StorageError extends ServiceError {
  const StorageError(String message, [dynamic original, StackTrace? stackTrace])
      : super(message, original, stackTrace);
}

/// Greška pri validaciji
class ValidationError extends ServiceError {
  const ValidationError(String message,
      [dynamic original, StackTrace? stackTrace])
      : super(message, original, stackTrace);
}
