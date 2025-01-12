import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/active_user.dart';

part 'active_users_provider.freezed.dart';
part 'active_users_provider.g.dart';

@freezed
class ActiveUsersState with _$ActiveUsersState {
  const factory ActiveUsersState({
    @Default([]) List<ActiveUser> users,
    @Default(false) bool isLoading,
    String? error,
  }) = _ActiveUsersState;
}

@riverpod
class ActiveUsers extends _$ActiveUsers {
  @override
  ActiveUsersState build() => const ActiveUsersState();

  Future<void> loadActiveUsers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: Implement actual API call to fetch active users
      await Future.delayed(const Duration(seconds: 1)); // Simulacija API poziva
      state = state.copyWith(
        users: [
          ActiveUser(
            id: '1',
            username: 'test_user',
            role: 'Regular User',
            lastActive: DateTime.now(),
            isOnline: true,
          ),
        ],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Greška pri učitavanju aktivnih korisnika: $e',
      );
    }
  }

  void updateUserStatus(String userId, bool isOnline) {
    final updatedUsers = state.users.map((user) {
      if (user.id == userId) {
        return user.copyWith(
          isOnline: isOnline,
          lastActive: DateTime.now(),
        );
      }
      return user;
    }).toList();

    state = state.copyWith(users: updatedUsers);
  }
}
