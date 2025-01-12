import 'dart:async';
import 'dart:convert';
import 'package:injectable/injectable.dart';
import '../interfaces/base_service.dart';
import '../interfaces/logger_service_interface.dart';
import '../interfaces/mesh_network_interface.dart';
import '../interfaces/cache_manager_interface.dart';
import '../models/message.dart';
import '../models/message_types.dart';
import 'cache_manager.dart';

@injectable
class DistributedCache implements IService {
  final ICacheManager _localCache;
  final MeshNetwork _mesh;
  final ILoggerService _logger;
  final _syncController = StreamController<CacheSync>.broadcast();
  bool _isInitialized = false;

  DistributedCache(
    this._logger,
    this._localCache,
    this._mesh,
  );

  /// Da li je servis inicijalizovan
  bool get isInitialized => _isInitialized;

  /// Stream za praćenje sinhronizacije keša
  Stream<CacheSync> get syncStream => _syncController.stream;

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      _logger.warning('${runtimeType.toString()}: Already initialized');
      return;
    }

    _logger.info('${runtimeType.toString()}: Initializing...');
    _listenToMeshUpdates();
    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    if (!_isInitialized) {
      _logger.warning('${runtimeType.toString()}: Not initialized');
      return;
    }

    _logger.info('${runtimeType.toString()}: Disposing...');
    await _syncController.close();
    _isInitialized = false;
  }

  void _listenToMeshUpdates() {
    _mesh.messageStream
        .where((msg) => msg.type == MessageType.cacheSync.value)
        .listen(_handleCacheSync);
  }

  Future<void> _handleCacheSync(Message message) async {
    final sync = CacheSync.fromMessage(message);
    await _localCache.updateMultiple(sync.updates);
    _syncController.add(sync);
  }

  /// Postavlja vrednost u keš
  Future<void> set(String key, dynamic value, {Duration? ttl}) async {
    if (!_isInitialized) {
      throw StateError('DistributedCache not initialized');
    }

    await _localCache.set(key, value, ttl: ttl);
    await _broadcastUpdate(key, value, ttl);
  }

  /// Vraća vrednost iz keša
  Future<dynamic> get(String key) async {
    if (!_isInitialized) {
      throw StateError('DistributedCache not initialized');
    }

    return _localCache.get(key);
  }

  /// Proverava da li postoji vrednost u kešu
  Future<bool> exists(String key) async {
    if (!_isInitialized) {
      throw StateError('DistributedCache not initialized');
    }

    return _localCache.exists(key);
  }

  /// Briše vrednost iz keša
  Future<void> remove(String key) async {
    if (!_isInitialized) {
      throw StateError('DistributedCache not initialized');
    }

    await _localCache.remove(key);
    await _broadcastRemove(key);
  }

  Future<void> _broadcastUpdate(
      String key, dynamic value, Duration? ttl) async {
    final sync = CacheSync(updates: {key: CacheEntry(value, ttl)});
    await _mesh.broadcast(sync.toMessage());
  }

  Future<void> _broadcastRemove(String key) async {
    final sync = CacheSync(updates: {key: CacheEntry(null, null)});
    await _mesh.broadcast(sync.toMessage());
  }
}

/// Klasa za sinhronizaciju keša
class CacheSync {
  final Map<String, CacheEntry> updates;

  CacheSync({required this.updates});

  Message toMessage() => Message(
        content: jsonEncode(updates),
        type: MessageType.cacheSync.value,
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'cache',
        recipientId: 'all',
        timestamp: DateTime.now(),
        priority: MessagePriority.normal.value,
      );

  static CacheSync fromMessage(Message message) => CacheSync(
        updates: Map<String, CacheEntry>.from(
          jsonDecode(message.content).map(
            (key, value) => MapEntry(
              key,
              CacheEntry.fromJson(value),
            ),
          ),
        ),
      );
}
