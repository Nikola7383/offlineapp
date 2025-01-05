class SecurityMemoryManager {
  static final SecurityMemoryManager _instance =
      SecurityMemoryManager._internal();

  final Map<String, WeakReference<Object>> _weakReferences = {};
  final StreamController<MemoryAlert> _alertStream =
      StreamController.broadcast();

  factory SecurityMemoryManager() {
    return _instance;
  }

  SecurityMemoryManager._internal() {
    _startMemoryMonitoring();
  }

  void _startMemoryMonitoring() {
    Timer.periodic(Duration(minutes: 1), (_) {
      _checkMemoryUsage();
    });
  }

  void _checkMemoryUsage() {
    // Čišćenje weak referenci
    _weakReferences.removeWhere((_, ref) => ref.target == null);

    // Provera memory thresholds
    if (_weakReferences.length > 1000) {
      _alertStream.add(MemoryAlert(
          type: MemoryAlertType.highUsage,
          message: 'High memory usage detected'));
    }
  }

  void registerObject(String key, Object object) {
    _weakReferences[key] = WeakReference(object);
  }

  Object? getObject(String key) {
    return _weakReferences[key]?.target;
  }

  Stream<MemoryAlert> get memoryAlerts => _alertStream.stream;
}

class MemoryAlert {
  final MemoryAlertType type;
  final String message;

  MemoryAlert({required this.type, required this.message});
}

enum MemoryAlertType { highUsage, criticalUsage, leakDetected }
