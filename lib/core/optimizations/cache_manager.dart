import 'dart:async';
import '../services/logger_service.dart';
import 'package:injectable/injectable.dart';
import 'package:service_locator/service_locator.dart';

@injectable
class CacheManager extends InjectableService implements Disposable {
  static const int MAX_CACHE_SIZE = 1000;
  static const Duration CACHE_DURATION = Duration(minutes: 30);

  final _cache = <String, CacheEntry>{};
  Timer? _cleanupTimer;

  CacheManager(LoggerService logger) : super(logger);

  @override
  Future<void> initialize() async {
    await super.initialize();
    _startCleanupTimer();
    ServiceLocator.instance.get<ResourceManager>().register('cache', this);
  }

  @override
  Future<void> dispose() async {
    _cleanupTimer?.cancel();
    _cache.clear();
    await super.dispose();
  }

  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _cleanup(),
    );
  }

  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null || entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    return entry.value as T;
  }

  void set<T>(String key, T value) {
    _cache[key] = CacheEntry(
      value: value,
      timestamp: DateTime.now(),
    );

    if (_cache.length > MAX_CACHE_SIZE) {
      _cleanup();
    }
  }

  void _cleanup() {
    final now = DateTime.now();
    _cache.removeWhere(
        (_, entry) => now.difference(entry.timestamp) > CACHE_DURATION);
  }

  Future<void> _preloadCache() async {
    // Implementirati ako je potrebno predučitavanje
    return Future.value();
  }
}

class CacheEntry {
  final dynamic value;
  final DateTime timestamp;

  CacheEntry({
    required this.value,
    required this.timestamp,
  });

  bool get isExpired =>
      DateTime.now().difference(timestamp) > CacheManager.CACHE_DURATION;
}
