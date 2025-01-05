@injectable
class DistributedCache extends InjectableService implements Disposable {
  final CacheManager _localCache;
  final MeshNetwork _mesh;
  final _syncController = StreamController<CacheSync>.broadcast();

  DistributedCache(
    LoggerService logger,
    this._localCache,
    this._mesh,
  ) : super(logger);

  @override
  Future<void> initialize() async {
    await super.initialize();
    _listenToMeshUpdates();
  }

  void _listenToMeshUpdates() {
    _mesh.messageStream
        .where((msg) => msg.type == MessageType.cacheSync)
        .listen(_handleCacheSync);
  }

  Future<void> _handleCacheSync(Message message) async {
    final sync = CacheSync.fromMessage(message);
    await _localCache.updateMultiple(sync.updates);
    _syncController.add(sync);
  }

  Future<void> set(String key, dynamic value, {Duration? ttl}) async {
    await _localCache.set(key, value, ttl: ttl);
    await _broadcastUpdate(key, value, ttl);
  }

  Future<void> _broadcastUpdate(
      String key, dynamic value, Duration? ttl) async {
    final sync = CacheSync(updates: {key: CacheEntry(value, ttl)});
    await _mesh.broadcast(sync.toMessage());
  }
}

class CacheSync {
  final Map<String, CacheEntry> updates;

  CacheSync({required this.updates});

  Message toMessage() => Message.create(
        content: jsonEncode(updates),
        type: MessageType.cacheSync,
      );

  static CacheSync fromMessage(Message message) => CacheSync(
        updates: Map<String, CacheEntry>.from(
          jsonDecode(message.content),
        ),
      );
}
