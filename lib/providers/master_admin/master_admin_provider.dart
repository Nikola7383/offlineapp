import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'master_admin_provider.freezed.dart';

@freezed
class MasterAdminState with _$MasterAdminState {
  const factory MasterAdminState({
    @Default(0) int activeNodes,
    @Default(0.0) double seedValidity,
    @Default(0) int totalMessages,
    @Default(0) int activeUsers,
    @Default(0.0) double averageResponseTime,
    @Default(0.0) double uptime,
    @Default(false) bool isLoading,
    String? error,
  }) = _MasterAdminState;
}

class MasterAdminNotifier extends StateNotifier<MasterAdminState> {
  MasterAdminNotifier() : super(const MasterAdminState()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      // TODO: Implementirati učitavanje podataka
      await Future.delayed(const Duration(seconds: 1)); // Simulacija

      state = state.copyWith(
        isLoading: false,
        activeNodes: 12,
        seedValidity: 0.85,
        totalMessages: 1458,
        activeUsers: 45,
        averageResponseTime: 150.5,
        uptime: 0.98,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshStatus() async {
    await _loadInitialData();
  }

  Future<void> refreshNodes() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      // TODO: Implementirati osvežavanje čvorova
      await Future.delayed(const Duration(seconds: 1)); // Simulacija

      state = state.copyWith(
        isLoading: false,
        activeNodes: state.activeNodes + 1, // Test promena
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshMessages() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      // TODO: Implementirati osvežavanje poruka
      await Future.delayed(const Duration(seconds: 1)); // Simulacija

      state = state.copyWith(
        isLoading: false,
        totalMessages: state.totalMessages + 10, // Test promena
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshUsers() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      // TODO: Implementirati osvežavanje korisnika
      await Future.delayed(const Duration(seconds: 1)); // Simulacija

      state = state.copyWith(
        isLoading: false,
        activeUsers: state.activeUsers + 2, // Test promena
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final masterAdminProvider =
    StateNotifierProvider<MasterAdminNotifier, MasterAdminState>((ref) {
  return MasterAdminNotifier();
});
