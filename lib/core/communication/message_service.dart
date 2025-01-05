import 'dart:async';
import '../base/base_service.dart';
import '../models/message.dart';
import '../services/logger_service.dart';
import '../interfaces/database_interface.dart';
import '../interfaces/mesh_interface.dart';
import '../interfaces/encryption_interface.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class MessageService extends BaseService {
  final DatabaseService _db;
  final MeshNetwork _mesh;
  final EncryptionService _encryption;

  MessageService({
    required DatabaseService db,
    required MeshNetwork mesh,
    required EncryptionService encryption,
    required LoggerService logger,
  })  : _db = db,
        _mesh = mesh,
        _encryption = encryption,
        super(logger: logger);

  Future<bool> sendMessage(String content, String senderId) async {
    return safeExecute(() async {
      final message = await _prepareMessage(content, senderId);
      await _saveAndBroadcast(message);
      return true;
    }, errorMessage: 'Greška pri slanju poruke', defaultValue: false);
  }

  Future<Message> _prepareMessage(String content, String senderId) async {
    final message = Message.create(
      content: content,
      senderId: senderId,
    );
    return await _encryption.encrypt(message);
  }

  Future<void> _saveAndBroadcast(Message message) async {
    await Future.wait([
      _db.saveMessage(message),
      _mesh.broadcast(message),
    ]);
  }

  // Primanje poruke
  Future<void> handleIncomingMessage(Message message) async {
    try {
      // Verifikuj integritet
      if (!await _encryption.verifyMessage(message)) {
        _logger.warning('Poruka nije prošla verifikaciju: ${message.id}');
        return;
      }

      // Proveri duplikat
      if (await _db.messageExists(message.id)) {
        return;
      }

      // Dekriptuj i sačuvaj
      final decrypted = await _encryption.decrypt(message);
      await _db.saveMessage(decrypted);

      // Propagiraj dalje kroz mesh
      await _mesh.relay(message);
    } catch (e) {
      _logger.error('Greška pri primanju poruke: $e');
    }
  }

  // Čitanje poruka
  Future<List<Message>> getMessages({
    DateTime? since,
    int limit = 50,
    String? senderId,
  }) async {
    try {
      final encrypted = await _db.getMessages(
        since: since,
        limit: limit,
        senderId: senderId,
      );

      final decrypted =
          await Future.wait(encrypted.map((e) => _encryption.decrypt(e)));

      return decrypted;
    } catch (e) {
      _logger.error('Greška pri čitanju poruka: $e');
      return [];
    }
  }
}
