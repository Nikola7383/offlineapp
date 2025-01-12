import 'dart:convert';
import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import 'package:pointycastle/asymmetric/api.dart';
import '../../core/interfaces/message_service_interface.dart';
import '../../core/interfaces/logger_service.dart';
import '../../core/interfaces/mesh_network_interface.dart';
import '../../core/models/message.dart';
import '../../core/models/encrypted_message.dart';
import '../encryption/encryption_service.dart';
import '../verification/message_verification_service.dart';

@LazySingleton(as: IMessageService)
class MessageService implements IMessageService {
  final EncryptionService _encryptionService;
  final MessageVerificationService _verificationService;
  final IMeshNetwork _meshNetwork;
  final ILoggerService _logger;

  final Map<String, EncryptedMessage> _messageCache = {};

  MessageService(
    this._encryptionService,
    this._verificationService,
    this._meshNetwork,
    this._logger,
  );

  @override
  Future<void> initialize() async {
    await _meshNetwork.initialize();
  }

  @override
  Future<void> dispose() async {
    await _meshNetwork.dispose();
    _messageCache.clear();
  }

  @override
  Stream<EncryptedMessage> get messageStream => _meshNetwork.messageStream;

  @override
  Future<void> sendMessage({
    required String recipientId,
    required String content,
    required String type,
    required int priority,
  }) async {
    try {
      final message = createMessage(
        recipientId: recipientId,
        content: content,
        type: type,
        priority: priority,
      );

      // Enkriptuj poruku
      final encryptedContent = await _encryptionService.encrypt(
        message.content,
        await _getRecipientPublicKey(recipientId),
      );

      final encryptedMessage = EncryptedMessage(
        id: message.id,
        senderId: message.senderId,
        recipientId: message.recipientId,
        content: encryptedContent,
        hash: _encryptionService.calculateHash(message.content),
        signature: await _encryptionService.sign(
          message.content,
          await _getCurrentUserPrivateKey(),
        ),
        timestamp: message.timestamp,
        type: message.type,
        priority: message.priority,
      );

      // Verifikuj pre slanja
      final verificationResult =
          await _verificationService.verifyMessage(encryptedMessage);
      if (!verificationResult.isValid) {
        throw Exception(
            'Message verification failed: ${verificationResult.failureReason}');
      }

      // Pošalji kroz mesh mrežu
      await _meshNetwork.broadcastMessage(encryptedMessage);

      // Keširaj poruku
      _messageCache[encryptedMessage.id] = encryptedMessage;

      _logger.info('Message sent successfully: ${message.id}');
    } catch (e) {
      _logger.error('Failed to send message', e);
      rethrow;
    }
  }

  @override
  EncryptedMessage? getMessage(String messageId) {
    return _messageCache[messageId];
  }

  @override
  void deleteMessage(String messageId) {
    _messageCache.remove(messageId);
  }

  @override
  void clearMessageCache() {
    _messageCache.clear();
  }

  @override
  Message createMessage({
    required String recipientId,
    required String content,
    required String type,
    required int priority,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: DateTime.now().toIso8601String(),
      senderId: 'current_user', // TODO: Implementirati getCurrentUser
      recipientId: recipientId,
      content: content,
      type: type,
      priority: priority,
      timestamp: DateTime.now(),
      metadata: metadata ?? {},
    );
  }

  @override
  Future<Message> receiveMessage(EncryptedMessage message) async {
    try {
      // Verifikuj primljenu poruku
      final verificationResult =
          await _verificationService.verifyMessage(message);
      if (!verificationResult.isValid) {
        throw Exception(
            'Received message verification failed: ${verificationResult.failureReason}');
      }

      // Dekriptuj poruku
      final decryptedContent = await _encryptionService.decrypt(
        message.content,
        await _getCurrentUserPrivateKey(),
      );

      // Keširaj enkriptovanu verziju
      _messageCache[message.id] = message;

      _logger.info('Message received successfully: ${message.id}');

      return Message(
        id: message.id,
        senderId: message.senderId,
        recipientId: message.recipientId,
        content: decryptedContent,
        type: message.type,
        priority: message.priority,
        timestamp: message.timestamp,
      );
    } catch (e) {
      _logger.error('Failed to receive message', e);
      rethrow;
    }
  }

  Future<RSAPublicKey> _getRecipientPublicKey(String recipientId) async {
    // TODO: Implementirati dobavljanje javnog ključa primaoca
    throw UnimplementedError(
        'Getting recipient public key is not implemented yet');
  }

  Future<RSAPrivateKey> _getCurrentUserPrivateKey() async {
    // TODO: Implementirati dobavljanje privatnog ključa trenutnog korisnika
    throw UnimplementedError(
        'Getting current user private key is not implemented yet');
  }
}
