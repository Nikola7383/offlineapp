import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'logs_provider.freezed.dart';

@freezed
class LogInfo with _$LogInfo {
  const factory LogInfo({
    required String level,
    required String message,
    required String timestamp,
    required String source,
    String? stackTrace,
  }) = _LogInfo;
}

@freezed
class LogsState with _$LogsState {
  const factory LogsState({
    @Default([]) List<LogInfo> logs,
    @Default('') String searchQuery,
    @Default(true) bool showError,
    @Default(true) bool showWarning,
    @Default(true) bool showInfo,
    @Default(false) bool showDebug,
    @Default(false) bool isLoading,
    String? error,
  }) = _LogsState;

  const LogsState._();

  List<LogInfo> get filteredLogs {
    return logs.where((log) {
      // Primeni filtere za nivo loga
      if (!showError && log.level.toUpperCase() == 'ERROR') return false;
      if (!showWarning && log.level.toUpperCase() == 'WARNING') return false;
      if (!showInfo && log.level.toUpperCase() == 'INFO') return false;
      if (!showDebug && log.level.toUpperCase() == 'DEBUG') return false;

      // Primeni pretragu
      if (searchQuery.isEmpty) return true;
      return log.message.toLowerCase().contains(searchQuery.toLowerCase()) ||
          log.source.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }
}

class LogsNotifier extends StateNotifier<LogsState> {
  LogsNotifier() : super(const LogsState()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      // TODO: Implementirati učitavanje podataka
      await Future.delayed(const Duration(seconds: 1)); // Simulacija

      state = state.copyWith(
        isLoading: false,
        logs: [
          const LogInfo(
            level: 'ERROR',
            message: 'Neuspešno povezivanje sa čvorom',
            timestamp: '2024-01-15 14:30:00',
            source: 'NetworkManager',
            stackTrace: '''
              at NetworkManager.connect (network_manager.dart:45)
              at MeshNetwork.addNode (mesh_network.dart:78)
              at main (main.dart:23)
            ''',
          ),
          const LogInfo(
            level: 'WARNING',
            message: 'Visoka upotreba memorije',
            timestamp: '2024-01-15 14:25:00',
            source: 'SystemMonitor',
          ),
          const LogInfo(
            level: 'INFO',
            message: 'Uspešno sinhronizovano 150 poruka',
            timestamp: '2024-01-15 14:20:00',
            source: 'MessageSync',
          ),
          const LogInfo(
            level: 'DEBUG',
            message: 'Inicijalizacija konfiguracije',
            timestamp: '2024-01-15 14:15:00',
            source: 'AppConfig',
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

  Future<void> refreshLogs() async {
    await _loadInitialData();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleErrorFilter(bool value) {
    state = state.copyWith(showError: value);
  }

  void toggleWarningFilter(bool value) {
    state = state.copyWith(showWarning: value);
  }

  void toggleInfoFilter(bool value) {
    state = state.copyWith(showInfo: value);
  }

  void toggleDebugFilter(bool value) {
    state = state.copyWith(showDebug: value);
  }
}

final logsProvider = StateNotifierProvider<LogsNotifier, LogsState>((ref) {
  return LogsNotifier();
});
