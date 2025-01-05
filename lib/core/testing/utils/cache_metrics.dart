@injectable
class CacheMetrics extends InjectableService {
  final CacheManager _cache;
  final Map<String, int> _accessCounts = {};
  final Map<String, int> _hitCounts = {};

  CacheMetrics(LoggerService logger, this._cache) : super(logger);

  Future<bool> measureCacheOperation(String key, dynamic value) async {
    _accessCounts[key] = (_accessCounts[key] ?? 0) + 1;

    try {
      // Prvo proverimo da li je u kešu
      final cached = await _cache.get(key);
      if (cached != null) {
        _hitCounts[key] = (_hitCounts[key] ?? 0) + 1;
        return true;
      }

      // Ako nije, dodajemo u keš
      await _cache.set(key, value);
      return false;
    } catch (e, stack) {
      logger.error('Cache operation failed', e, stack);
      return false;
    }
  }

  double getHitRatio(String key) {
    final accesses = _accessCounts[key] ?? 0;
    if (accesses == 0) return 0.0;
    return (_hitCounts[key] ?? 0) / accesses;
  }

  void resetMetrics() {
    _accessCounts.clear();
    _hitCounts.clear();
  }
}
