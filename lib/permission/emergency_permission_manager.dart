class EmergencyPermissionManager {
  // Core permissions
  final AudioPermissionHandler _audioHandler;
  final StoragePermissionHandler _storageHandler;
  final DevicePermissionHandler _deviceHandler;

  // Permission states
  final PermissionStateManager _stateManager;
  final PermissionMonitor _monitor;
  final PermissionGuard _guard;

  // App lifecycle
  final AppLifecycleManager _lifecycleManager;
  final PermissionResetter _resetter;

  EmergencyPermissionManager()
      : _audioHandler = AudioPermissionHandler(),
        _storageHandler = StoragePermissionHandler(),
        _deviceHandler = DevicePermissionHandler(),
        _stateManager = PermissionStateManager(),
        _monitor = PermissionMonitor(),
        _guard = PermissionGuard(),
        _lifecycleManager = AppLifecycleManager(),
        _resetter = PermissionResetter() {
    _initializePermissions();
  }

  Future<void> _initializePermissions() async {
    await _lifecycleManager.onAppStart(() async {
      await _requestCriticalPermissions();
      await _startPermissionMonitoring();
    });

    await _lifecycleManager.onAppStop(() async {
      await _resetPermissions();
    });
  }

  Future<bool> requestCriticalPermissions() async {
    try {
      // 1. Audio permissions for seed transfer
      final audioGranted = await _audioHandler.requestPermission(
          options: PermissionOptions(temporary: true, critical: true));
      if (!audioGranted) return false;

      // 2. Storage for secure data
      final storageGranted = await _storageHandler.requestPermission(
          options: PermissionOptions(temporary: true, secure: true));
      if (!storageGranted) return false;

      // 3. Device permissions
      final deviceGranted = await _deviceHandler.requestPermission(
          options: PermissionOptions(temporary: true, minimal: true));
      if (!deviceGranted) return false;

      await _stateManager.updatePermissionState(PermissionState.granted,
          timestamp: DateTime.now());

      return true;
    } catch (e) {
      await _handlePermissionError(e);
      return false;
    }
  }

  Future<void> _resetPermissions() async {
    await _guard.guardedOperation(() async {
      await _resetter.resetAllPermissions();
      await _stateManager.updatePermissionState(PermissionState.reset,
          timestamp: DateTime.now());
    });
  }

  Stream<PermissionEvent> monitorPermissions() async* {
    await for (final event in _monitor.startMonitoring()) {
      if (_isPermissionCritical(event)) {
        yield event;
      }
    }
  }
}

enum PermissionState { initial, requesting, granted, denied, reset }
