import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'users_provider.freezed.dart';

@freezed
class UserInfo with _$UserInfo {
  const factory UserInfo({
    required String id,
    required String name,
    required String role,
    required bool isActive,
    required String lastActivity,
    required int messageCount,
    required double uptime,
  }) = _UserInfo;
}

@freezed
class UsersState with _$UsersState {
  const factory UsersState({
    @Default([]) List<UserInfo> users,
    @Default('all') String filter,
    @Default(false) bool isLoading,
    String? error,
  }) = _UsersState;

  const UsersState._();

  List<UserInfo> get filteredUsers {
    switch (filter) {
      case 'active':
        return users.where((user) => user.isActive).toList();
      case 'inactive':
        return users.where((user) => !user.isActive).toList();
      default:
        return users;
    }
  }

  int get activeUsers => users.where((user) => user.isActive).length;
  int get inactiveUsers => users.where((user) => !user.isActive).length;
}

class UsersNotifier extends StateNotifier<UsersState> {
  UsersNotifier() : super(const UsersState()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      // TODO: Implementirati učitavanje podataka
      await Future.delayed(const Duration(seconds: 1)); // Simulacija

      state = state.copyWith(
        isLoading: false,
        users: [
          const UserInfo(
            id: '1',
            name: 'Petar Petrović',
            role: 'Master Admin',
            isActive: true,
            lastActivity: '2024-01-15 14:30',
            messageCount: 145,
            uptime: 0.98,
          ),
          const UserInfo(
            id: '2',
            name: 'Marko Marković',
            role: 'Glasnik',
            isActive: true,
            lastActivity: '2024-01-15 14:25',
            messageCount: 89,
            uptime: 0.95,
          ),
          const UserInfo(
            id: '3',
            name: 'Jovan Jovanović',
            role: 'Regular User',
            isActive: false,
            lastActivity: '2024-01-15 10:15',
            messageCount: 56,
            uptime: 0.75,
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

  Future<void> refreshUsers() async {
    await _loadInitialData();
  }

  void setFilter(String filter) {
    state = state.copyWith(filter: filter);
  }

  Future<void> activateUser(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      // TODO: Implementirati aktivaciju korisnika
      await Future.delayed(const Duration(seconds: 1)); // Simulacija

      final updatedUsers = state.users.map((user) {
        if (user.id == userId) {
          return user.copyWith(isActive: true);
        }
        return user;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        users: updatedUsers,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> removeUser(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      // TODO: Implementirati uklanjanje korisnika
      await Future.delayed(const Duration(seconds: 1)); // Simulacija

      final updatedUsers =
          state.users.where((user) => user.id != userId).toList();

      state = state.copyWith(
        isLoading: false,
        users: updatedUsers,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final usersProvider = StateNotifierProvider<UsersNotifier, UsersState>((ref) {
  return UsersNotifier();
});
