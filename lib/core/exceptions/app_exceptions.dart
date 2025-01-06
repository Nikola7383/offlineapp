class AppException implements Exception {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  AppException(this.message, {this.code, this.stackTrace});

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

class SecurityException extends AppException {
  SecurityException(String message, {String? code, StackTrace? stackTrace})
      : super(message, code: code, stackTrace: stackTrace);
}

class NetworkException extends AppException {
  NetworkException(String message, {String? code, StackTrace? stackTrace})
      : super(message, code: code, stackTrace: stackTrace);
}

class StorageException extends AppException {
  StorageException(String message, {String? code, StackTrace? stackTrace})
      : super(message, code: code, stackTrace: stackTrace);
}
