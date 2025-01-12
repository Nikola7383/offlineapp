import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'active_users_provider.freezed.dart';
part 'active_users_provider.g.dart';

@freezed
class ActiveUser with _$ActiveUser {
  const factory ActiveUser({
    required String id,
    required String name,
    required String role,
    required bool isOnline,
    required String lastActivity,
    required String ipAddress,
    String? location,
  }) = _ActiveUser;

  factory ActiveUser.fromJson(Map<String, dynamic> json) =>
      _$ActiveUserFromJson(json);
}

@freezed
class ActiveUsersState with _$ActiveUsersState {
  const factory ActiveUsersState({
    required List<ActiveUser> users,
    required int totalUsers,
    required int onlineUsers,
    required int offlineUsers,
    required List<String> availableRoles,
    required List<String> selectedRoles,
    required bool showOnlineOnly,
    @Default(false) bool isLoading,
  }) = _ActiveUsersState;
}

class ActiveUsersNotifier extends StateNotifier<ActiveUsersState> {
  ActiveUsersNotifier()
      : super(
          const ActiveUsersState(
            users: [],
            totalUsers: 0,
            onlineUsers: 0,
            offlineUsers: 0,
            availableRoles: ['Admin', 'Moderator', 'User', 'Guest'],
            selectedRoles: [],
            showOnlineOnly: false,
          ),
        );

  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true);
    try {
      // TODO: Implementirati učitavanje korisnika
      await Future.delayed(
          const Duration(seconds: 1)); // Simulacija mrežnog poziva

      final mockUsers = [
        const ActiveUser(
          id: '1',
          name: 'John Doe',
          role: 'Admin',
          isOnline: true,
          lastActivity: '2024-01-20 15:30',
          ipAddress: '192.168.1.100',
          location: 'Belgrade, Serbia',
        ),
        const ActiveUser(
          id: '2',
          name: 'Jane Smith',
          role: 'Moderator',
          isOnline: true,
          lastActivity: '2024-01-20 15:25',
          ipAddress: '192.168.1.101',
        ),
        const ActiveUser(
          id: '3',
          name: 'Bob Johnson',
          role: 'User',
          isOnline: false,
          lastActivity: '2024-01-20 14:45',
          ipAddress: '192.168.1.102',
          location: 'Novi Sad, Serbia',
        ),
      ];

      state = state.copyWith(
        isLoading: false,
        users: mockUsers,
        totalUsers: mockUsers.length,
        onlineUsers: mockUsers.where((user) => user.isOnline).length,
        offlineUsers: mockUsers.where((user) => !user.isOnline).length,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> sendMessage(String userId, String message) async {
    // TODO: Implementirati slanje poruke
    await Future.delayed(const Duration(seconds: 1)); // Simulacija slanja
  }

  Future<void> disconnectUser(String userId) async {
    state = state.copyWith(isLoading: true);
    try {
      // TODO: Implementirati prekid veze
      await Future.delayed(const Duration(seconds: 1)); // Simulacija prekida

      final updatedUsers = state.users.map((user) {
        if (user.id == userId) {
          return user.copyWith(isOnline: false);
        }
        return user;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        users: updatedUsers,
        onlineUsers: state.onlineUsers - 1,
        offlineUsers: state.offlineUsers + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> blockUser(String userId, String reason) async {
    state = state.copyWith(isLoading: true);
    try {
      // TODO: Implementirati blokiranje
      await Future.delayed(const Duration(seconds: 1)); // Simulacija blokiranja

      final updatedUsers =
          state.users.where((user) => user.id != userId).toList();

      state = state.copyWith(
        isLoading: false,
        users: updatedUsers,
        totalUsers: state.totalUsers - 1,
        onlineUsers: state.onlineUsers -
            (state.users.firstWhere((u) => u.id == userId).isOnline ? 1 : 0),
        offlineUsers: state.offlineUsers -
            (state.users.firstWhere((u) => u.id == userId).isOnline ? 0 : 1),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  void toggleOnlineFilter(bool value) {
    state = state.copyWith(showOnlineOnly: value);
    _applyFilters();
  }

  void toggleRoleFilter(String role) {
    final updatedRoles = List<String>.from(state.selectedRoles);
    if (updatedRoles.contains(role)) {
      updatedRoles.remove(role);
    } else {
      updatedRoles.add(role);
    }
    state = state.copyWith(selectedRoles: updatedRoles);
    _applyFilters();
  }

  void clearFilters() {
    state = state.copyWith(
      showOnlineOnly: false,
      selectedRoles: [],
    );
    _applyFilters();
  }

  void _applyFilters() {
    // TODO: Implementirati filtriranje
    loadUsers(); // Privremeno rešenje - ponovno učitavanje
  }
}

final activeUsersProvider =
    StateNotifierProvider<ActiveUsersNotifier, ActiveUsersState>((ref) {
  return ActiveUsersNotifier();
});
