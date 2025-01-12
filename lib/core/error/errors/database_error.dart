import '../error_listener.dart';

class DatabaseError extends AppError {
  final String operation;
  final String table;

  DatabaseError({
    required String message,
    required this.operation,
    required this.table,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          code: 'DATABASE_ERROR',
          message: message,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}
