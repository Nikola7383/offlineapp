import 'dart:async';
import 'package:injectable/injectable.dart';
import '../auth/auth_service.dart';
import '../mesh/mesh_network.dart';
import '../interfaces/message_service_interface.dart';
import '../storage/database_service.dart';
import '../notifications/notification_service.dart';
import '../settings/settings_service.dart';
import '../security/encryption_service.dart';
import '../logging/logger_service.dart';
import '../models/message.dart';

class AppService {
  final AuthService auth;
  final MeshNetwork mesh;
  final IMessageService messaging;
  final DatabaseService storage;
  final NotificationService notifications;
  final SettingsService settings;
  final EncryptionService encryption;
  final LoggerService logger;

  bool _isInitialized = false;
  final _messageController = StreamController<Message>.broadcast();

  Stream<Message> get messageStream => _messageController.stream;

  AppService({
    required this.auth,
    required this.mesh,
    required this.messaging,
    required this.storage,
    required this.notifications,
    required this.settings,
    required this.encryption,
    required this.logger,
  });

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      logger.info('Initializing AppService...');

      // 1. Inicijalizacija settings-a prvo jer druge komponente mogu zavisiti od njih
      await settings.initialize();
      await settings.setDefaultSettings();

      // 2. Inicijalizacija auth servisa
      final authInitialized = await auth.initialize();
      if (!authInitialized) {
        logger.warning('Auth service initialization failed');
      }

      // 3. Inicijalizacija storage-a
      await storage.initialize();

      // 4. Inicijalizacija notifikacija
      await notifications.initialize();

      // 5. Postavljanje mesh network listenera
      mesh.messageStream.listen(_handleIncomingMessage);

      _isInitialized = true;
      logger.info('AppService initialized successfully');
      return true;
    } catch (e) {
      logger.error('Failed to initialize AppService', e);
      return false;
    }
  }

  Future<void> _handleIncomingMessage(Message message) async {
    try {
      // 1. Dekriptuj poruku ako je potrebno
      final decryptedMessage = message.type == MessageType.encrypted
          ? await encryption.decrypt(message as EncryptedMessage)
          : message;

      // 2. Sačuvaj u storage
      await storage.saveMessage(decryptedMessage);

      // 3. Proveri settings za notifikacije
      final notificationsEnabled =
          settings.getSetting<bool>('notifications_enabled') ?? true;

      if (notificationsEnabled && auth.currentUser?.id != message.senderId) {
        await notifications.showMessageNotification(decryptedMessage);
      }

      // 4. Emituj poruku svim listenerima
      _messageController.add(decryptedMessage);
    } catch (e) {
      logger.error('Failed to handle incoming message', e);
    }
  }

  Future<bool> sendMessage(String content) async {
    try {
      if (!_isInitialized) {
        throw AppException('AppService not initialized');
      }

      final currentUser = auth.currentUser;
      if (currentUser == null) {
        throw AppException('User not authenticated');
      }

      // 1. Kreiraj poruku
      final message = Message(
        id: DateTime.now().toIso8601String(),
        content: content,
        senderId: currentUser.id,
        timestamp: DateTime.now(),
      );

      // 2. Enkriptuj
      final encrypted = await encryption.encrypt(message);

      // 3. Sačuvaj lokalno
      await storage.saveMessage(message);

      // 4. Pošalji preko mesh mreže
      final sent = await mesh.broadcast(encrypted);
      if (!sent) {
        throw AppException('Failed to send message');
      }

      // 5. Emituj poruku lokalno
      _messageController.add(message);

      return true;
    } catch (e) {
      logger.error('Failed to send message', e);
      return false;
    }
  }

  Future<List<Message>> getRecentMessages({int limit = 50}) async {
    try {
      return await storage.getMessages(limit: limit);
    } catch (e) {
      logger.error('Failed to get recent messages', e);
      return [];
    }
  }

  Future<void> dispose() async {
    await _messageController.close();
  }
}

class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => 'AppException: $message';
}
