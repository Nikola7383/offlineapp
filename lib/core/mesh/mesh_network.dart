import 'dart:convert';
import 'package:nearby_connections/nearby_connections.dart';
import '../models/message.dart';
import '../logging/logger_service.dart';
import 'strategy.dart';
import 'base_service.dart';
import 'dart:async';
import '../interfaces/mesh_interface.dart';
import '../models/device_info.dart';
import 'mesh_optimizer.dart';
import 'mesh_load_balancer.dart';
import 'cache_manager.dart';
import 'package:get_it/get_it.dart';

class MeshNetwork extends InjectableService
    implements MeshInterface, Disposable {
  final String _serviceId = 'com.glasnik.mesh';
  final Set<String> _connectedPeers = {};
  final _messageController = StreamController<Message>.broadcast();
  final _connectionController = StreamController<PeerConnection>.broadcast();

  final MeshOptimizer _optimizer;
  final MeshLoadBalancer _loadBalancer;
  final CacheManager _cache;

  MeshNetwork(
    LoggerService logger,
    this._optimizer,
    this._loadBalancer,
    this._cache,
  ) : super(logger);

  @override
  Future<void> initialize() async {
    await super.initialize();
    await _setupNearby();
    GetIt.I<ResourceManager>().register('mesh', this);
  }

  @override
  Future<void> dispose() async {
    await stop();
    _messageController.close();
    await super.dispose();
  }

  Stream<Message> get messageStream => _messageController.stream;
  Stream<PeerConnection> get connectionStream => _connectionController.stream;
  Set<String> get connectedPeers => Set.unmodifiable(_connectedPeers);

  Future<void> _setupNearby() async {
    await Nearby().startAdvertising(
      await DeviceInfo.deviceId,
      Strategy.P2P_CLUSTER,
      onConnectionInitiated: _handleConnection,
      onConnectionResult: _handleConnectionResult,
      onDisconnected: _handleDisconnection,
    );

    await Nearby().startDiscovery(
      await DeviceInfo.deviceId,
      Strategy.P2P_CLUSTER,
      onEndpointFound: _handleEndpointFound,
      onEndpointLost: _handleEndpointLost,
    );
  }

  Future<bool> broadcast(Message message) async {
    return safeExecute(() async {
      final payload = _messageToPayload(message);
      final futures = _connectedPeers
          .map((peerId) => Nearby().sendPayload(peerId, payload));
      await Future.wait(futures);
      return true;
    }, errorMessage: 'Greška pri broadcast-u', defaultValue: false);
  }

  void _handleConnection(String id, ConnectionInfo info) {
    safeExecute(() async {
      await Nearby().acceptConnection(
        id,
        onPayLoadRecieved: _onPayloadReceived,
        onPayloadTransferUpdate: _onPayloadTransferUpdate,
      );
    }, errorMessage: 'Greška pri prihvatanju konekcije');
  }

  void _onPayloadReceived(String id, Payload payload) {
    safeExecute(() async {
      if (payload.type == PayloadType.BYTES) {
        final message = _payloadToMessage(payload);
        _messageController.add(message);
      }
    }, errorMessage: 'Greška pri primanju payload-a');
  }

  Payload _messageToPayload(Message message) {
    final bytes = utf8.encode(jsonEncode(message.toMap()));
    return Payload(
      type: PayloadType.BYTES,
      bytes: bytes,
    );
  }

  Message _payloadToMessage(Payload payload) {
    final map = jsonDecode(utf8.decode(payload.bytes));
    return Message.fromMap(map);
  }

  void _onPayloadTransferUpdate(String id, PayloadTransferUpdate update) {
    safeExecute(() {
      switch (update.status) {
        case PayloadStatus.SUCCESS:
          _optimizer.trackPeerMetrics(
            id,
            update.bytesTransferred ~/ 1024, // kao proxy za latency
            1,
          );
          break;
        case PayloadStatus.FAILURE:
          logger.warning('Neuspešan prenos za peer: $id');
          break;
        default:
          // U toku
          break;
      }
    }, errorMessage: 'Greška pri update-u transfera');
  }
}

class PeerConnection {
  final String peerId;
  final ConnectionStatus status;

  PeerConnection(this.peerId, this.status);
}

enum ConnectionStatus { connected, disconnected, failed }
