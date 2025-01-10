import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/broadcast/broadcast_message.dart';
import '../../services/broadcast/broadcast_service.dart';

final broadcastsProvider = StateNotifierProvider<BroadcastNotifier,
    AsyncValue<List<BroadcastMessage>>>((ref) {
  final broadcastService = ref.watch(broadcastServiceProvider);
  return BroadcastNotifier(broadcastService);
});

final urgentBroadcastsProvider = StateNotifierProvider<UrgentBroadcastNotifier,
    AsyncValue<List<BroadcastMessage>>>((ref) {
  final broadcastService = ref.watch(broadcastServiceProvider);
  return UrgentBroadcastNotifier(broadcastService);
});

class BroadcastNotifier
    extends StateNotifier<AsyncValue<List<BroadcastMessage>>> {
  final BroadcastService _broadcastService;

  BroadcastNotifier(this._broadcastService)
      : super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final broadcasts = await _broadcastService.getActiveBroadcasts();
      state = AsyncValue.data(broadcasts);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final broadcasts = await _broadcastService.getActiveBroadcasts();
      state = AsyncValue.data(broadcasts);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> createBroadcast({
    required String content,
    required String senderId,
    bool isUrgent = false,
  }) async {
    try {
      await _broadcastService.createBroadcast(
        content: content,
        senderId: senderId,
        isUrgent: isUrgent,
      );
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deactivateBroadcast(String broadcastId) async {
    try {
      await _broadcastService.deactivateBroadcast(broadcastId);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class UrgentBroadcastNotifier
    extends StateNotifier<AsyncValue<List<BroadcastMessage>>> {
  final BroadcastService _broadcastService;

  UrgentBroadcastNotifier(this._broadcastService)
      : super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final broadcasts = await _broadcastService.getUrgentBroadcasts();
      state = AsyncValue.data(broadcasts);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final broadcasts = await _broadcastService.getUrgentBroadcasts();
      state = AsyncValue.data(broadcasts);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
