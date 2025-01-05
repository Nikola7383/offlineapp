@injectable
class EvictionPolicy extends InjectableService {
  static const MAX_MEMORY_USAGE = 100 * 1024 * 1024; // 100MB
  final _lruList = LinkedHashMap<String, DateTime>();

  Future<void> shouldEvict(CacheManager cache) async {
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

  void recordAccess(String key) {
    _lruList
      ..remove(key)
      ..putIfAbsent(key, () => DateTime.now());
  }
}
