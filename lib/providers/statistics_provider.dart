import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/statistics.dart';

part 'statistics_provider.freezed.dart';
part 'statistics_provider.g.dart';

@freezed
class StatisticsState with _$StatisticsState {
  const factory StatisticsState({
    Statistics? data,
    @Default(false) bool isLoading,
    String? error,
  }) = _StatisticsState;
}

@riverpod
class StatisticsNotifier extends _$StatisticsNotifier {
  @override
  StatisticsState build() => const StatisticsState();

  Future<void> loadStatistics() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(
        data: Statistics(
          totalUsers: 100,
          activeUsers: 50,
          totalMessages: 1000,
          messagesPerHour: 42,
          networkHealth: 0.95,
          usersByRole: {
            'admin': 5,
            'user': 95,
          },
          recentEvents: [
            NetworkEvent(
              type: 'connection',
              description: 'New user connected',
              timestamp: DateTime.now(),
              severity: 'info',
            ),
          ],
        ),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error loading statistics: $e',
      );
    }
  }
}
