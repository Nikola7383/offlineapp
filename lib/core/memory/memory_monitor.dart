import 'package:injectable/injectable.dart';

@injectable
class MemoryMonitor extends InjectableService {
  static const MEMORY_CHECK_INTERVAL = Duration(minutes: 5);
  static const MEMORY_THRESHOLD = 500 * 1024 * 1024; // 500MB

  Timer? _monitorTimer;
  final Map<String, WeakReference<Object>> _objectTracker = {};

  @override
  Future<void> initialize() async {
    await super.initialize();
    _startMonitoring();
  }

  void _startMonitoring() {
    _monitorTimer = Timer.periodic(
      MEMORY_CHECK_INTERVAL,
      (_) => _checkMemoryUsage(),
    );
  }

  void trackObject(String id, Object object) {
    _objectTracker[id] = WeakReference(object);
  }

  Future<void> _checkMemoryUsage() async {
    final usage = await _getCurrentMemoryUsage();
    if (usage > MEMORY_THRESHOLD) {
      logger.warning('High memory usage detected: ${usage ~/ 1024 / 1024}MB');
      _cleanupUnusedObjects();
    }
  }

  void _cleanupUnusedObjects() {
    _objectTracker.removeWhere((_, ref) => ref.target == null);
  }
}
