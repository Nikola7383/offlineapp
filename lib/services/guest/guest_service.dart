import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/interfaces/base_service.dart';
import '../../core/database/database_service.dart';
import '../../core/security/encryption_service.dart';
import '../../models/user/guest_user.dart';

class GuestService extends BaseService {
  final DatabaseService _db;
  final EncryptionService _encryption;

  GuestService(this._db, this._encryption);

  static const Duration defaultGuestDuration = Duration(hours: 48);

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

  Future<GuestUser> createGuest({
    Duration validity = defaultGuestDuration,
  }) async {
    final deviceId = await _encryption.generateSecureDeviceId();
    final now = DateTime.now();

    final guest = GuestUser(
      id: _encryption.generateUuid(),
      deviceId: deviceId,
      createdAt: now,
      updatedAt: now,
      expiresAt: now.add(validity),
      isActive: true,
    );

    await _db.saveGuest(guest);
    return guest;
  }

  Future<GuestUser?> getGuest(String guestId) async {
    return await _db.getGuest(guestId);
  }

  Future<void> deactivateGuest(String guestId) async {
    final guest = await _db.getGuest(guestId);
    if (guest != null) {
      final updated = guest.copyWith(
        isActive: false,
        updatedAt: DateTime.now(),
      );
      await _db.saveGuest(updated);
    }
  }

  Future<void> recordBroadcastReceived(
      String guestId, String broadcastId) async {
    final guest = await _db.getGuest(guestId);
    if (guest != null && guest.canReceiveBroadcasts) {
      final updated = guest.copyWithReceived(broadcastId);
      await _db.saveGuest(updated);
    }
  }

  Future<bool> canReceiveBroadcast(String guestId) async {
    final guest = await _db.getGuest(guestId);
    return guest?.canReceiveBroadcasts ?? false;
  }

  Future<void> cleanupExpiredGuests() async {
    final guests = await _db.getAllGuests();
    for (final guest in guests) {
      if (guest.isExpired) {
        await deactivateGuest(guest.id);
      }
    }
  }
}

// Provider
final guestServiceProvider = Provider<GuestService>((ref) {
  final db = ref.watch(databaseServiceProvider);
  final encryption = ref.watch(encryptionServiceProvider);
  return GuestService(db, encryption);
});
