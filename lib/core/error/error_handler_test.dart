@isTest
class ErrorHandlingTest extends TestCase {
  late ErrorHandler _errorHandler;
  late MockErrorListener _mockListener;

  @override
  Future<void> setUp() async {
    _errorHandler = GetIt.instance.get<ErrorHandler>();
    _mockListener = MockErrorListener();
    GetIt.instance.get<ErrorObserver>().addListener(_mockListener);
  }

  @override
  String get name => 'Error Handling Test';

  @override
  Future<void> run() async {
    await _testNetworkError();
    await _testDatabaseError();
    await _testSecurityError();
    await _testDefaultError();
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
    expect(_mockListener.lastError.code, 'NETWORK_ERROR');
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
    expect(_mockListener.lastError.code, 'DATABASE_ERROR');
  }
}

class MockErrorListener implements ErrorListener {
  AppError? lastError;

  @override
  void onError(AppError error) {
    lastError = error;
  }
}
