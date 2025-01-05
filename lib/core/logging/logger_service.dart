abstract class LoggerService {
  Future<void> info(String message);
  Future<void> warning(String message);
  Future<void> error(String message, [dynamic error]);
}

class LoggerServiceImpl implements LoggerService {
  @override
  Future<void> info(String message) async {
    print('INFO: $message');
  }

  @override
  Future<void> warning(String message) async {
    print('WARNING: $message');
  }

  @override
  Future<void> error(String message, [dynamic error]) async {
    print('ERROR: $message');
    if (error != null) {
      print('Error details: $error');
    }
  }
}
