import '../models/message.dart';
import '../logging/logger_service.dart';
import '../security/encryption_service.dart';
import '../mesh/mesh_network.dart';

class MessageService {
  final LoggerService logger;
  final EncryptionService encryption;
  final MeshNetwork mesh;

  final List<Message> _messageCache = [];

  MessageService({
    required this.logger,
    required this.encryption,
    required this.mesh,
  });

  Future<bool> sendMessage(Message message) async {
    try {
      logger.info('Sending message: ${message.id}');

      // Enkriptuj poruku
      final encrypted = await encryption.encrypt(message);

      // Sačuvaj u lokalnom kešu
      _messageCache.add(message);

      // Pošalji preko mesh mreže
      return await mesh.broadcast(message);
    } catch (e) {
      logger.error('Failed to send message', e);
      return false;
    }
  }

  Future<List<Message>> getRecentMessages({int limit = 50}) async {
    try {
      return _messageCache.take(limit).toList();
    } catch (e) {
      logger.error('Failed to get recent messages', e);
      return [];
    }
  }

  Future<void> handleIncomingMessage(Message message) async {
    try {
      logger.info('Handling incoming message: ${message.id}');

      // Verifikuj i dekriptuj ako je potrebno
      if (message.type == MessageType.encrypted) {
        final decrypted = await encryption.decrypt(message as EncryptedMessage);
        _messageCache.add(decrypted);
      } else {
        _messageCache.add(message);
      }
    } catch (e) {
      logger.error('Failed to handle incoming message', e);
      rethrow;
    }
  }
}
