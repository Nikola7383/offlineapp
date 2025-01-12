import 'package:injectable/injectable.dart';
import 'package:test/test.dart';
import 'package:get_it/get_it.dart';
import '../testing/test_framework.dart';
import 'error_handler.dart';
import 'error_observer.dart';
import 'error_listener.dart';
import 'errors/network_error.dart';
import 'errors/database_error.dart';
import 'exceptions/network_exception.dart';
import 'exceptions/database_exception.dart';

@injectable
class ErrorHandlingTest extends TestCase {
  late ErrorHandler _errorHandler;
  late MockErrorListener _mockListener;
  late ErrorObserver _observer;

  @override
  Future<void> setUp() async {
    _observer = ErrorObserver();
    _errorHandler = ErrorHandler(_observer);
    _mockListener = MockErrorListener();
    _observer.addListener(_mockListener);
  }

  @override
  String get name => 'Error Handling Test';

  @override
  Future<void> run() async {
    await _testNetworkError();
    await _testDatabaseError();
  }

  Future<void> _testNetworkError() async {
    await _errorHandler.handleError(() async {
      throw NetworkException(
        'Connection failed',
        statusCode: 500,
        endpoint: '/api/test',
      );
    });

    expect(_mockListener.lastError is NetworkError, true);
    expect(_mockListener.lastError?.code, 'NETWORK_ERROR');
  }

  Future<void> _testDatabaseError() async {
    await _errorHandler.handleError(() async {
      throw DatabaseException(
        'Insert failed',
        operation: 'INSERT',
        table: 'users',
      );
    });

    expect(_mockListener.lastError is DatabaseError, true);
    expect(_mockListener.lastError?.code, 'DATABASE_ERROR');
  }
}

class MockErrorListener implements ErrorListener {
  AppError? lastError;

  @override
  void onError(AppError error) {
    lastError = error;
  }
}
