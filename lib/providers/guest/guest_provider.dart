import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user/guest_user.dart';
import '../../services/guest/guest_service.dart';

final guestProvider =
    StateNotifierProvider<GuestNotifier, AsyncValue<GuestUser?>>((ref) {
  final guestService = ref.watch(guestServiceProvider);
  return GuestNotifier(guestService);
});

class GuestNotifier extends StateNotifier<AsyncValue<GuestUser?>> {
  final GuestService _guestService;

  GuestNotifier(this._guestService) : super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final guest = await _guestService.createGuest();
      state = AsyncValue.data(guest);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final guest = await _guestService.createGuest();
      state = AsyncValue.data(guest);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> recordBroadcastReceived(String broadcastId) async {
    final currentGuest = state.value;
    if (currentGuest == null) return;

    try {
      await _guestService.recordBroadcastReceived(currentGuest.id, broadcastId);
      final updatedGuest = await _guestService.getGuest(currentGuest.id);
      if (updatedGuest != null) {
        state = AsyncValue.data(updatedGuest);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deactivate() async {
    final currentGuest = state.value;
    if (currentGuest == null) return;

    try {
      await _guestService.deactivateGuest(currentGuest.id);
      final updatedGuest = await _guestService.getGuest(currentGuest.id);
      if (updatedGuest != null) {
        state = AsyncValue.data(updatedGuest);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
