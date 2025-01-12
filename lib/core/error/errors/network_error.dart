import '../error_listener.dart';

class NetworkError extends AppError {
  final int statusCode;
  final String endpoint;

  NetworkError({
    required String message,
    required this.statusCode,
    required this.endpoint,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          code: 'NETWORK_ERROR',
          message: message,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}
