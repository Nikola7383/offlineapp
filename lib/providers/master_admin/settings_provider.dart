import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_provider.freezed.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    // Mrežna podešavanja
    @Default(10) int maxNodes,
    @Default(60) int syncInterval,
    @Default(true) bool autoSync,

    // Bezbednosna podešavanja
    @Default('AES-256') String encryptionLevel,
    @Default(false) bool twoFactorAuth,
    @Default(30) int sessionTimeout,

    // Podešavanja logovanja
    @Default('INFO') String logLevel,
    @Default(100) int maxLogSize,
    @Default(false) bool verboseLogging,

    // Status
    @Default(false) bool isLoading,
    String? error,
  }) = _SettingsState;
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());

  Future<void> loadSettings() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      // TODO: Implementirati učitavanje podešavanja
      await Future.delayed(const Duration(seconds: 1)); // Simulacija

      // Za sada vraćamo podrazumevana podešavanja
      state = const SettingsState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> saveSettings() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      // TODO: Implementirati čuvanje podešavanja
      await Future.delayed(const Duration(seconds: 1)); // Simulacija

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> resetToDefaults() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      // TODO: Implementirati resetovanje podešavanja
      await Future.delayed(const Duration(seconds: 1)); // Simulacija

      state = const SettingsState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Mrežna podešavanja
  void updateMaxNodes(int value) {
    state = state.copyWith(maxNodes: value);
  }

  void updateSyncInterval(int value) {
    state = state.copyWith(syncInterval: value);
  }

  void updateAutoSync(bool value) {
    state = state.copyWith(autoSync: value);
  }

  // Bezbednosna podešavanja
  void updateEncryptionLevel(String value) {
    state = state.copyWith(encryptionLevel: value);
  }

  void updateTwoFactorAuth(bool value) {
    state = state.copyWith(twoFactorAuth: value);
  }

  void updateSessionTimeout(int value) {
    state = state.copyWith(sessionTimeout: value);
  }

  // Podešavanja logovanja
  void updateLogLevel(String value) {
    state = state.copyWith(logLevel: value);
  }

  void updateMaxLogSize(int value) {
    state = state.copyWith(maxLogSize: value);
  }

  void updateVerboseLogging(bool value) {
    state = state.copyWith(verboseLogging: value);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
