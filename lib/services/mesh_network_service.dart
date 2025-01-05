import 'package:nearby_connections/nearby_connections.dart';

class MeshNetworkService {
  final Strategy _strategy = Strategy.P2P_CLUSTER;
  final String _serviceId = 'com.glasnik.mesh';
  final LoggerService _logger;
  final DatabaseService _db;

  MeshNetworkService({
    required LoggerService logger,
    required DatabaseService db,
  })  : _logger = logger,
        _db = db;

  Future<void> startAdvertising() async {
    try {
      await Nearby().startAdvertising(
        DeviceInfo.deviceId,
        _strategy,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      );
    } catch (e) {
      _logger.error('Greška pri oglašavanju: $e');
    }
  }

  Future<void> startDiscovery() async {
    try {
      await Nearby().startDiscovery(
        DeviceInfo.deviceId,
        _strategy,
        onEndpointFound: _onEndpointFound,
        onEndpointLost: _onEndpointLost,
      );
    } catch (e) {
      _logger.error('Greška pri otkrivanju: $e');
    }
  }

  // Kada se pronađe novi uređaj
  void _onEndpointFound(String id, String userName, String serviceId) {
    if (serviceId == _serviceId) {
      Nearby().requestConnection(
        DeviceInfo.deviceId,
        id,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      );
    }
  }

  // Razmena poruka između uređaja
  Future<void> shareMessages(String endpointId) async {
    try {
      final messages = await _db.getUnsharedMessages();
      for (final msg in messages) {
        final payload = Payload.fromBytes(utf8.encode(jsonEncode(msg.toMap())));
        await Nearby().sendPayload(endpointId, payload);
      }
    } catch (e) {
      _logger.error('Greška pri deljenju poruka: $e');
    }
  }
}
