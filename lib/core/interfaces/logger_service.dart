/// Interfejs za logging servis
abstract class ILoggerService extends IService {
  Future<void> debug(String message, [Map<String, dynamic>? context]);
  Future<void> info(String message, [Map<String, dynamic>? context]);
  Future<void> warning(String message, [Map<String, dynamic>? context]);
  Future<void> error(String message, [dynamic error, StackTrace? stackTrace]);
}
