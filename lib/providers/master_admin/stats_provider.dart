import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'stats_provider.freezed.dart';

@freezed
class ActivityData with _$ActivityData {
  const factory ActivityData({
    required DateTime timestamp,
    required int messageCount,
    required int activeUsers,
    required double networkLoad,
  }) = _ActivityData;
}

@freezed
class StatsState with _$StatsState {
  const factory StatsState({
    @Default(0) int activeNodes,
    @Default(0.0) double averageResponseTime,
    @Default(0.0) double uptime,
    @Default(0) int totalMessages,
    @Default(0) int deliveredMessages,
    @Default(0) int failedMessages,
    @Default(0) int activeUsers,
    @Default(0.0) double averageMessagesPerUser,
    @Default('') String mostActiveUser,
    @Default([]) List<ActivityData> activityData,
    @Default(false) bool isLoading,
    String? error,
  }) = _StatsState;
}

class StatsNotifier extends StateNotifier<StatsState> {
  StatsNotifier() : super(const StatsState()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      // TODO: Implementirati učitavanje podataka
      await Future.delayed(const Duration(seconds: 1)); // Simulacija

      final now = DateTime.now();
      final activityData = List.generate(
        24,
        (i) => ActivityData(
          timestamp: now.subtract(Duration(hours: 23 - i)),
          messageCount: 50 + (i * 2),
          activeUsers: 10 + (i % 5),
          networkLoad: 0.4 + (i % 3) * 0.1,
        ),
      );

      state = state.copyWith(
        isLoading: false,
        activeNodes: 5,
        averageResponseTime: 150.0,
        uptime: 0.985,
        totalMessages: 1250,
        deliveredMessages: 1180,
        failedMessages: 70,
        activeUsers: 25,
        averageMessagesPerUser: 50.0,
        mostActiveUser: 'Petar Petrović',
        activityData: activityData,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshStats() async {
    await _loadInitialData();
  }
}

final statsProvider = StateNotifierProvider<StatsNotifier, StatsState>((ref) {
  return StatsNotifier();
});
