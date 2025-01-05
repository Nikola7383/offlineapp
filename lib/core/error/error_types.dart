class AppError implements Exception {
  final String code;
  final String message;
  final ErrorSeverity severity;
  final Map<String, dynamic> context;
  final StackTrace? stackTrace;

  AppError({
    required this.code,
    required this.message,
    this.severity = ErrorSeverity.error,
    this.context = const {},
    this.stackTrace,
  });

  bool get isCritical => severity == ErrorSeverity.critical;
  bool get isRecoverable => severity == ErrorSeverity.warning;
}

enum ErrorSeverity {
  info,
  warning,
  error,
  critical,
}

class NetworkError extends AppError {
  final int? statusCode;
  final String? endpoint;

  NetworkError({
    required String message,
    this.statusCode,
    this.endpoint,
    Map<String, dynamic> context = const {},
  }) : super(
          code: 'NETWORK_ERROR',
          message: message,
          severity: ErrorSeverity.error,
          context: {
            ...context,
            'statusCode': statusCode,
            'endpoint': endpoint,
          },
        );
}

class DatabaseError extends AppError {
  final String? operation;
  final String? table;

  DatabaseError({
    required String message,
    this.operation,
    this.table,
    Map<String, dynamic> context = const {},
  }) : super(
          code: 'DATABASE_ERROR',
          message: message,
          severity: ErrorSeverity.critical,
          context: {
            ...context,
            'operation': operation,
            'table': table,
          },
        );
}

class SecurityError extends AppError {
  SecurityError({
    required String message,
    Map<String, dynamic> context = const {},
  }) : super(
          code: 'SECURITY_ERROR',
          message: message,
          severity: ErrorSeverity.critical,
          context: context,
        );
}
