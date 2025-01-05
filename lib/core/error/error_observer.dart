@injectable
class ErrorObserver extends InjectableService {
  final ErrorHandler _errorHandler;
  final List<ErrorListener> _listeners = [];

  ErrorObserver(
    LoggerService logger,
    this._errorHandler,
  ) : super(logger) {
    _initializeErrorListening();
  }

  void addListener(ErrorListener listener) {
    _listeners.add(listener);
  }

  void removeListener(ErrorListener listener) {
    _listeners.remove(listener);
  }

  void _initializeErrorListening() {
    _errorHandler.errorStream.listen((error) {
      for (final listener in _listeners) {
        try {
          listener.onError(error);
        } catch (e, stack) {
          logger.error('Error listener failed', e, stack);
        }
      }

      if (error.isCritical) {
        _handleCriticalError(error);
      }
    });
  }

  void _handleCriticalError(AppError error) {
    logger.critical(
      'Critical error occurred',
      error,
      error.stackTrace,
      extras: error.context,
    );
    // Implementirati recovery mehanizam
  }
}

abstract class ErrorListener {
  void onError(AppError error);
}
