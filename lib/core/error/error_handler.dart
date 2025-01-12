import 'package:injectable/injectable.dart';
import 'error_observer.dart';
import 'error_listener.dart';
import 'errors/network_error.dart';
import 'errors/database_error.dart';
import 'exceptions/network_exception.dart';
import 'exceptions/database_exception.dart';

@injectable
class ErrorHandler {
  final ErrorObserver _observer;

  ErrorHandler(this._observer);

  Future<void> handleError(Future<void> Function() operation) async {
    try {
      await operation();
    } on NetworkException catch (e, stack) {
      final error = NetworkError(
        message: e.message,
        statusCode: e.statusCode,
        endpoint: e.endpoint,
        originalError: e,
        stackTrace: stack,
      );
      _observer.notifyError(error);
      rethrow;
    } on DatabaseException catch (e, stack) {
      final error = DatabaseError(
        message: e.message,
        operation: e.operation,
        table: e.table,
        originalError: e,
        stackTrace: stack,
      );
      _observer.notifyError(error);
      rethrow;
    } catch (e, stack) {
      final error = AppError(
        code: 'UNKNOWN_ERROR',
        message: e.toString(),
        originalError: e,
        stackTrace: stack,
      );
      _observer.notifyError(error);
      rethrow;
    }
  }
}
