import '../models/encrypted_message.dart';
import '../models/message.dart';
import 'base_service.dart';

/// Interfejs za servis za upravljanje porukama
abstract class IMessageService implements IService {
  /// Vraća stream poruka
  Stream<EncryptedMessage> get messageStream;

  /// Šalje poruku
  Future<void> sendMessage({
    required String recipientId,
    required String content,
    required String type,
    required int priority,
  });

  /// Vraća poruku iz keša
  EncryptedMessage? getMessage(String messageId);

  /// Briše poruku iz keša
  void deleteMessage(String messageId);

  /// Čisti keš poruka
  void clearMessageCache();

  /// Kreira novu poruku
  Message createMessage({
    required String recipientId,
    required String content,
    required String type,
    required int priority,
    Map<String, dynamic>? metadata,
  });

  /// Prima i dekriptuje poruku
  Future<Message> receiveMessage(EncryptedMessage message);
}
