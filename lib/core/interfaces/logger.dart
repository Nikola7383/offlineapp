abstract class Logger {
  Future<void> info(String message, [Map<String, dynamic>? context]);
  Future<void> warning(String message, [Map<String, dynamic>? context]);
  Future<void> error(String message, [dynamic error, StackTrace? stackTrace]);
  Future<void> debug(String message, [Map<String, dynamic>? context]);
}
