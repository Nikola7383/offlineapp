import 'dart:async';
import '../models/message.dart';
import '../storage/database_service.dart';
import '../mesh/mesh_network.dart';
import '../security/encryption_service.dart';
import '../logging/logger_service.dart';

class SyncService {
  final DatabaseService storage;
  final MeshNetwork mesh;
  final EncryptionService encryption;
  final LoggerService logger;

  Timer? _syncTimer;
  DateTime _lastSyncTime = DateTime.now();
  bool _isSyncing = false;

  SyncService({
    required this.storage,
    required this.mesh,
    required this.encryption,
    required this.logger,
  });

  Future<void> startSync(
      {Duration interval = const Duration(minutes: 1)}) async {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(interval, (_) => synchronize());

    // Inicijalna sinhronizacija
    await synchronize();
  }

  Future<SyncResult> synchronize() async {
    if (_isSyncing) {
      logger.info('Sync already in progress, skipping...');
      return SyncResult(success: false, reason: 'Sync in progress');
    }

    _isSyncing = true;
    try {
      logger.info('Starting synchronization...');

      // 1. Dobavi nove poruke sa mreže
      final networkMessages = await _getNewNetworkMessages();

      // 2. Dobavi lokalne poruke koje nisu sinhronizovane
      final localMessages = await _getUnsyncedLocalMessages();

      // 3. Reši konflikte
      final conflicts = _findConflicts(networkMessages, localMessages);
      await _resolveConflicts(conflicts);

      // 4. Sačuvaj nove poruke lokalno
      for (final message in networkMessages) {
        await storage.saveMessage(message);
      }

      // 5. Pošalji lokalne poruke na mrežu
      for (final message in localMessages) {
        final encrypted = await encryption.encrypt(message);
        await mesh.broadcast(encrypted);
      }

      _lastSyncTime = DateTime.now();

      return SyncResult(
        success: true,
        messagesReceived: networkMessages.length,
        messagesSent: localMessages.length,
      );
    } catch (e) {
      logger.error('Synchronization failed', e);
      return SyncResult(success: false, reason: e.toString());
    } finally {
      _isSyncing = false;
    }
  }

  Future<List<Message>> _getNewNetworkMessages() async {
    try {
      // Implementacija zavisi od mesh network API-ja
      return [];
    } catch (e) {
      logger.error('Failed to get network messages', e);
      return [];
    }
  }

  Future<List<Message>> _getUnsyncedLocalMessages() async {
    try {
      return await storage.getMessages(since: _lastSyncTime);
    } catch (e) {
      logger.error('Failed to get unsynced local messages', e);
      return [];
    }
  }

  List<MessageConflict> _findConflicts(
    List<Message> networkMessages,
    List<Message> localMessages,
  ) {
    final conflicts = <MessageConflict>[];

    for (final network in networkMessages) {
      for (final local in localMessages) {
        if (network.id == local.id && network.timestamp != local.timestamp) {
          conflicts.add(MessageConflict(network, local));
        }
      }
    }

    return conflicts;
  }

  Future<void> _resolveConflicts(List<MessageConflict> conflicts) async {
    for (final conflict in conflicts) {
      // Uzmi noviju verziju
      final winner = conflict.networkMessage.timestamp.isAfter(
        conflict.localMessage.timestamp,
      )
          ? conflict.networkMessage
          : conflict.localMessage;

      await storage.saveMessage(winner);
    }
  }

  void dispose() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }
}

class SyncResult {
  final bool success;
  final String? reason;
  final int messagesReceived;
  final int messagesSent;

  SyncResult({
    required this.success,
    this.reason,
    this.messagesReceived = 0,
    this.messagesSent = 0,
  });
}

class MessageConflict {
  final Message networkMessage;
  final Message localMessage;

  MessageConflict(this.networkMessage, this.localMessage);
}
