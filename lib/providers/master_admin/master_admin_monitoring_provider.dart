import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'master_admin_monitoring_provider.freezed.dart';

@freezed
class AdminInfo with _$AdminInfo {
  const factory AdminInfo({
    required String id,
    required String name,
    required DateTime activeSince,
    required double seedValidity,
    required int nodeCount,
    required int messageCount,
    required double uptime,
  }) = _AdminInfo;
}

@freezed
class PendingAdminInfo with _$PendingAdminInfo {
  const factory PendingAdminInfo({
    required String id,
    required String name,
    required DateTime requestDate,
  }) = _PendingAdminInfo;
}

@freezed
class AdminHistoryEntry with _$AdminHistoryEntry {
  const factory AdminHistoryEntry({
    required String id,
    required String name,
    required DateTime date,
    required bool isSuccess,
    required String description,
  }) = _AdminHistoryEntry;
}

@freezed
class MasterAdminMonitoringState with _$MasterAdminMonitoringState {
  const factory MasterAdminMonitoringState({
    @Default([]) List<AdminInfo> activeAdmins,
    @Default([]) List<PendingAdminInfo> pendingAdmins,
    @Default([]) List<AdminHistoryEntry> history,
    @Default(false) bool isLoading,
    String? error,
  }) = _MasterAdminMonitoringState;
}

class MasterAdminMonitoringNotifier
    extends StateNotifier<MasterAdminMonitoringState> {
  MasterAdminMonitoringNotifier() : super(const MasterAdminMonitoringState()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // TODO: Implementirati učitavanje podataka
      await Future.delayed(const Duration(seconds: 1)); // Simulacija

      state = state.copyWith(
        isLoading: false,
        activeAdmins: [
          AdminInfo(
            id: '1',
            name: 'Admin 1',
            activeSince: DateTime.now().subtract(const Duration(days: 30)),
            seedValidity: 0.8,
            nodeCount: 12,
            messageCount: 145,
            uptime: 0.98,
          ),
          AdminInfo(
            id: '2',
            name: 'Admin 2',
            activeSince: DateTime.now().subtract(const Duration(days: 15)),
            seedValidity: 0.9,
            nodeCount: 8,
            messageCount: 89,
            uptime: 0.95,
          ),
        ],
        pendingAdmins: [
          PendingAdminInfo(
            id: '3',
            name: 'Pending Admin 1',
            requestDate: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
        history: [
          AdminHistoryEntry(
            id: '4',
            name: 'Admin 3',
            date: DateTime.now().subtract(const Duration(days: 5)),
            isSuccess: true,
            description: 'Uspešno verifikovan',
          ),
          AdminHistoryEntry(
            id: '5',
            name: 'Admin 4',
            date: DateTime.now().subtract(const Duration(days: 7)),
            isSuccess: false,
            description: 'Verifikacija istekla',
          ),
        ],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> approveAdmin(String adminId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // TODO: Implementirati odobravanje admin-a
      await Future.delayed(const Duration(seconds: 1)); // Simulacija

      final pendingAdmin =
          state.pendingAdmins.firstWhere((admin) => admin.id == adminId);
      final updatedPendingAdmins =
          List<PendingAdminInfo>.from(state.pendingAdmins)
            ..removeWhere((admin) => admin.id == adminId);

      final newActiveAdmin = AdminInfo(
        id: pendingAdmin.id,
        name: pendingAdmin.name,
        activeSince: DateTime.now(),
        seedValidity: 1.0,
        nodeCount: 0,
        messageCount: 0,
        uptime: 1.0,
      );

      final updatedActiveAdmins = List<AdminInfo>.from(state.activeAdmins)
        ..add(newActiveAdmin);

      final newHistoryEntry = AdminHistoryEntry(
        id: pendingAdmin.id,
        name: pendingAdmin.name,
        date: DateTime.now(),
        isSuccess: true,
        description: 'Uspešno verifikovan',
      );

      final updatedHistory = List<AdminHistoryEntry>.from(state.history)
        ..insert(0, newHistoryEntry);

      state = state.copyWith(
        isLoading: false,
        activeAdmins: updatedActiveAdmins,
        pendingAdmins: updatedPendingAdmins,
        history: updatedHistory,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> rejectAdmin(String adminId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // TODO: Implementirati odbijanje admin-a
      await Future.delayed(const Duration(seconds: 1)); // Simulacija

      final pendingAdmin =
          state.pendingAdmins.firstWhere((admin) => admin.id == adminId);
      final updatedPendingAdmins =
          List<PendingAdminInfo>.from(state.pendingAdmins)
            ..removeWhere((admin) => admin.id == adminId);

      final newHistoryEntry = AdminHistoryEntry(
        id: pendingAdmin.id,
        name: pendingAdmin.name,
        date: DateTime.now(),
        isSuccess: false,
        description: 'Zahtev odbijen',
      );

      final updatedHistory = List<AdminHistoryEntry>.from(state.history)
        ..insert(0, newHistoryEntry);

      state = state.copyWith(
        isLoading: false,
        pendingAdmins: updatedPendingAdmins,
        history: updatedHistory,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> revokeAdmin(String adminId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // TODO: Implementirati opoziv admin-a
      await Future.delayed(const Duration(seconds: 1)); // Simulacija

      final admin =
          state.activeAdmins.firstWhere((admin) => admin.id == adminId);
      final updatedActiveAdmins = List<AdminInfo>.from(state.activeAdmins)
        ..removeWhere((a) => a.id == adminId);

      final newHistoryEntry = AdminHistoryEntry(
        id: admin.id,
        name: admin.name,
        date: DateTime.now(),
        isSuccess: false,
        description: 'Pristup opozvan',
      );

      final updatedHistory = List<AdminHistoryEntry>.from(state.history)
        ..insert(0, newHistoryEntry);

      state = state.copyWith(
        isLoading: false,
        activeAdmins: updatedActiveAdmins,
        history: updatedHistory,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await _loadInitialData();
  }
}

final masterAdminMonitoringProvider = StateNotifierProvider<
    MasterAdminMonitoringNotifier, MasterAdminMonitoringState>((ref) {
  return MasterAdminMonitoringNotifier();
});
