import 'package:geolocator/geolocator.dart';
import 'dart:async';

class GeoFencingCore {
  static final GeoFencingCore _instance = GeoFencingCore._internal();
  final Map<String, GeoFence> _activeFences = {};
  final Map<String, StreamSubscription<Position>> _locationSubscriptions = {};
  final double _defaultRadius = 100.0; // metri

  factory GeoFencingCore() {
    return _instance;
  }

  GeoFencingCore._internal();

  Future<void> createGeoFence(
      {required String fenceId,
      required double latitude,
      required double longitude,
      double? radius,
      required List<String> authorizedDevices}) async {
    final fence = GeoFence(
        id: fenceId,
        center: Position(
            latitude: latitude,
            longitude: longitude,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0),
        radius: radius ?? _defaultRadius,
        authorizedDevices: authorizedDevices);

    _activeFences[fenceId] = fence;
    await _startMonitoring(fence);
  }

  Future<void> _startMonitoring(GeoFence fence) async {
    final locationStream = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
            accuracy: LocationAccuracy.high, distanceFilter: 10));

    _locationSubscriptions[fence.id] =
        locationStream.listen((Position position) {
      _checkFenceViolation(fence, position);
    });
  }

  Future<void> _checkFenceViolation(GeoFence fence, Position position) async {
    final distance = Geolocator.distanceBetween(fence.center.latitude,
        fence.center.longitude, position.latitude, position.longitude);

    if (distance > fence.radius) {
      await _handleFenceViolation(fence, position);
    }
  }

  Future<void> _handleFenceViolation(GeoFence fence, Position position) async {
    // Implementacija reakcije na kršenje geo-fence-a
    await SecurityCore().logSecurityEvent('GEO_FENCE_VIOLATION', {
      'fence_id': fence.id,
      'position': {'lat': position.latitude, 'lng': position.longitude},
      'timestamp': DateTime.now().toIso8601String()
    });
  }

  Future<bool> isDeviceInFence(String deviceId, String fenceId) async {
    final fence = _activeFences[fenceId];
    if (fence == null) return false;

    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final distance = Geolocator.distanceBetween(fence.center.latitude,
          fence.center.longitude, position.latitude, position.longitude);

      return distance <= fence.radius;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    for (var subscription in _locationSubscriptions.values) {
      subscription.cancel();
    }
    _locationSubscriptions.clear();
  }
}

class GeoFence {
  final String id;
  final Position center;
  final double radius;
  final List<String> authorizedDevices;

  GeoFence(
      {required this.id,
      required this.center,
      required this.radius,
      required this.authorizedDevices});
}
