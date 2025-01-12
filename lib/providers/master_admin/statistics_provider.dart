import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'statistics_provider.freezed.dart';
part 'statistics_provider.g.dart';

@freezed
class StatisticsState with _$StatisticsState {
  const factory StatisticsState({
    required int totalMessages,
    required int activeUsers,
    required int averageResponseTime,
    required int transferSuccess,
    required int activeNodes,
    required List<int> messagesByHour,
    required List<int> usersByDay,
    @Default(false) bool isLoading,
  }) = _StatisticsState;
}

class StatisticsNotifier extends StateNotifier<StatisticsState> {
  StatisticsNotifier()
      : super(
          const StatisticsState(
            totalMessages: 0,
            activeUsers: 0,
            averageResponseTime: 0,
            transferSuccess: 0,
            activeNodes: 0,
            messagesByHour: [],
            usersByDay: [],
          ),
        );

  Future<void> loadStatistics() async {
    state = state.copyWith(isLoading: true);
    try {
      // TODO: Implementirati učitavanje statistike
      await Future.delayed(
          const Duration(seconds: 1)); // Simulacija mrežnog poziva

      // Simulirani podaci
      final mockMessagesByHour = List.generate(24, (i) => 50 + (i * 10) % 100);
      final mockUsersByDay = List.generate(7, (i) => 100 + (i * 20) % 150);

      state = state.copyWith(
        isLoading: false,
        totalMessages: 1234,
        activeUsers: 56,
        averageResponseTime: 78,
        transferSuccess: 99,
        activeNodes: 7,
        messagesByHour: mockMessagesByHour,
        usersByDay: mockUsersByDay,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> exportStatistics() async {
    state = state.copyWith(isLoading: true);
    try {
      // TODO: Implementirati izvoz statistike
      await Future.delayed(const Duration(seconds: 2)); // Simulacija izvoza
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
}

final statisticsProvider =
    StateNotifierProvider<StatisticsNotifier, StatisticsState>((ref) {
  return StatisticsNotifier();
});
