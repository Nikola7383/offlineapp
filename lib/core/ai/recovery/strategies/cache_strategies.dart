class CacheEvictionStrategy extends RecoveryStrategy {
  static const MEMORY_THRESHOLD = 0.8; // 80%

  @override
  Future<RecoveryResult> execute(HealthIssue issue) async {
    try {
      final cache = GetIt.instance<CacheManager>();
      final metrics = await cache.getMetrics();

      if (metrics.memoryUsage > MEMORY_THRESHOLD) {
        // Evict least recently used items
        final evictedCount = await cache.evictLRU(
          targetMemoryUsage: MEMORY_THRESHOLD * 0.7,
        );

        return RecoveryResult(
          successful: true,
          message: 'Cache eviction successful',
          metrics: {
            'evictedItems': evictedCount,
            'newMemoryUsage': (await cache.getMetrics()).memoryUsage,
          },
        );
      }

      return RecoveryResult(
        successful: true,
        message: 'Cache eviction not needed',
        metrics: {'currentMemoryUsage': metrics.memoryUsage},
      );
    } catch (e) {
      return RecoveryResult(
        successful: false,
        message: 'Cache eviction failed: $e',
      );
    }
  }
}

class CacheResyncStrategy extends RecoveryStrategy {
  @override
  Future<RecoveryResult> execute(HealthIssue issue) async {
    try {
      final cache = GetIt.instance<CacheManager>();
      final peers = GetIt.instance<MeshNetwork>().getConnectedPeers();

      int syncedPeers = 0;
      for (final peer in peers) {
        try {
          await cache.syncWithPeer(peer.id);
          syncedPeers++;
        } catch (e) {
          // Continue with other peers if one fails
          continue;
        }
      }

      return RecoveryResult(
        successful: syncedPeers > 0,
        message: 'Cache resynced with $syncedPeers peers',
        metrics: {
          'syncedPeers': syncedPeers,
          'totalPeers': peers.length,
        },
      );
    } catch (e) {
      return RecoveryResult(
        successful: false,
        message: 'Cache resync failed: $e',
      );
    }
  }
}
