import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'secret_master_provider.freezed.dart';

@freezed
class SecretMasterState with _$SecretMasterState {
  const factory SecretMasterState({
    @Default(false) bool isGeneratingQR,
    @Default(false) bool isGeneratingSound,
    @Default([]) List<String> activeAdmins,
    @Default([]) List<String> pendingAdmins,
    @Default(null) String? lastError,
    @Default(false) bool isLoading,
  }) = _SecretMasterState;
}

class SecretMasterNotifier extends StateNotifier<SecretMasterState> {
  SecretMasterNotifier() : super(const SecretMasterState());

  Future<void> generateQRCode() async {
    try {
      state = state.copyWith(isGeneratingQR: true, lastError: null);
      // TODO: Implementirati QR generisanje
      await Future.delayed(const Duration(seconds: 2)); // Simulacija
      state = state.copyWith(isGeneratingQR: false);
    } catch (e) {
      state = state.copyWith(
        isGeneratingQR: false,
        lastError: e.toString(),
      );
    }
  }

  Future<void> generateSoundSignal() async {
    try {
      state = state.copyWith(isGeneratingSound: true, lastError: null);
      // TODO: Implementirati generisanje zvučnog signala
      await Future.delayed(const Duration(seconds: 2)); // Simulacija
      state = state.copyWith(isGeneratingSound: false);
    } catch (e) {
      state = state.copyWith(
        isGeneratingSound: false,
        lastError: e.toString(),
      );
    }
  }

  Future<void> refreshAdminStatus() async {
    try {
      state = state.copyWith(isLoading: true, lastError: null);
      // TODO: Implementirati osvežavanje statusa admin-a
      await Future.delayed(const Duration(seconds: 1)); // Simulacija
      state = state.copyWith(
        isLoading: false,
        activeAdmins: ['Admin 1', 'Admin 2'], // Test podaci
        pendingAdmins: ['Pending Admin 1'], // Test podaci
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        lastError: e.toString(),
      );
    }
  }

  Future<void> approveAdmin(String adminId) async {
    try {
      state = state.copyWith(isLoading: true, lastError: null);
      // TODO: Implementirati odobravanje admin-a
      await Future.delayed(const Duration(seconds: 1)); // Simulacija

      final updatedPendingAdmins = List<String>.from(state.pendingAdmins)
        ..remove(adminId);
      final updatedActiveAdmins = List<String>.from(state.activeAdmins)
        ..add(adminId);

      state = state.copyWith(
        isLoading: false,
        activeAdmins: updatedActiveAdmins,
        pendingAdmins: updatedPendingAdmins,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        lastError: e.toString(),
      );
    }
  }

  Future<void> revokeAdmin(String adminId) async {
    try {
      state = state.copyWith(isLoading: true, lastError: null);
      // TODO: Implementirati opoziv admin-a
      await Future.delayed(const Duration(seconds: 1)); // Simulacija

      final updatedActiveAdmins = List<String>.from(state.activeAdmins)
        ..remove(adminId);

      state = state.copyWith(
        isLoading: false,
        activeAdmins: updatedActiveAdmins,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        lastError: e.toString(),
      );
    }
  }
}

final secretMasterProvider =
    StateNotifierProvider<SecretMasterNotifier, SecretMasterState>((ref) {
  return SecretMasterNotifier();
});
