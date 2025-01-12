import 'dart:collection';
import 'package:injectable/injectable.dart';
import '../interfaces/base_service.dart';
import 'cache_manager.dart';

@injectable
class EvictionPolicy implements IService {
  static const MAX_MEMORY_USAGE = 100 * 1024 * 1024; // 100MB
  final _lruList = LinkedHashMap<String, DateTime>();
  bool _isInitialized = false;

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    _isInitialized = false;
    _lruList.clear();
  }

  Future<void> shouldEvict(CacheManager cache) async {
    if (!_isInitialized) return;
    final memoryUsage = await _getMemoryUsage(cache);

    if (memoryUsage > MAX_MEMORY_USAGE) {
      await _evictLRU(cache);
    }
  }

  Future<void> _evictLRU(CacheManager cache) async {
    final entriesToEvict = _lruList.entries
        .take(_lruList.length ~/ 4) // Evict 25% of entries
        .map((e) => e.key)
        .toList();

    for (final key in entriesToEvict) {
      await cache.remove(key);
      _lruList.remove(key);
    }
  }

  Future<int> _getMemoryUsage(CacheManager cache) async {
    // TODO: Implement actual memory usage calculation
    return 0;
  }

  void recordAccess(String key) {
    _lruList[key] = DateTime.now();
  }
}
