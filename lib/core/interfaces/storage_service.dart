import '../models/message.dart';
import '../models/result.dart';

/// Interfejs za storage servis
abstract class IStorageService extends IService {
  /// Čuva poruku
  Future<Result<void>> saveMessage(Message message);

  /// Briše poruku
  Future<Result<void>> deleteMessage(String messageId);

  /// Vraća poruke sa paginacijom
  Future<Result<List<Message>>> getMessages();

  /// Čisti sve poruke
  Future<Result<void>> clearMessages();
}
