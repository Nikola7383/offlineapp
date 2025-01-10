import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/interfaces/base_service.dart';
import '../../core/database/database_service.dart';
import '../../core/security/encryption_service.dart';
import '../../models/broadcast/broadcast_message.dart';

class BroadcastService extends BaseService {
  final DatabaseService _db;
  final EncryptionService _encryption;

  BroadcastService(this._db, this._encryption);

  @override
  Future<void> initialize() async {
    await _db.initialize();
    await _encryption.initialize();
  }

  @override
  Future<void> dispose() async {
    await _db.dispose();
    await _encryption.dispose();
  }

  Future<BroadcastMessage> createBroadcast({
    required String content,
    required String senderId,
    bool isUrgent = false,
  }) async {
    final now = DateTime.now();
    final message = BroadcastMessage(
      id: _encryption.generateUuid(),
      content: await _encryption.encrypt(content, senderId),
      senderId: senderId,
      createdAt: now,
      updatedAt: now,
      isUrgent: isUrgent,
      isActive: true,
    );

    await _db.saveBroadcast(message);
    return message;
  }

  Future<BroadcastMessage?> getBroadcast(String broadcastId) async {
    return await _db.getBroadcast(broadcastId);
  }

  Future<List<BroadcastMessage>> getActiveBroadcasts() async {
    return await _db.getActiveBroadcasts();
  }

  Future<List<BroadcastMessage>> getUrgentBroadcasts() async {
    return await _db.getUrgentBroadcasts();
  }

  Future<void> deactivateBroadcast(String broadcastId) async {
    final broadcast = await _db.getBroadcast(broadcastId);
    if (broadcast != null) {
      final updated = broadcast.copyWith(
        isActive: false,
        updatedAt: DateTime.now(),
      );
      await _db.saveBroadcast(updated);
    }
  }

  Future<void> markBroadcastAsReceived(
      String broadcastId, String userId) async {
    final broadcast = await _db.getBroadcast(broadcastId);
    if (broadcast != null) {
      final updated = broadcast.markAsReceived(userId);
      await _db.saveBroadcast(updated);
    }
  }

  Future<void> cleanupOldBroadcasts({
    Duration maxAge = const Duration(days: 7),
  }) async {
    final cutoff = DateTime.now().subtract(maxAge);
    final broadcasts = await _db.getAllBroadcasts();
    for (final broadcast in broadcasts) {
      if (broadcast.createdAt.isBefore(cutoff)) {
        await deactivateBroadcast(broadcast.id);
      }
    }
  }
}

// Provider
final broadcastServiceProvider = Provider<BroadcastService>((ref) {
  final db = ref.watch(databaseServiceProvider);
  final encryption = ref.watch(encryptionServiceProvider);
  return BroadcastService(db, encryption);
});
