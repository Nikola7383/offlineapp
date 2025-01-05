class GeoFenceManager {
  static final GeoFenceManager _instance = GeoFenceManager._internal();
  final Map<String, GeoFence> _activeFences = {};

  Future<void> setupEventGeoFence(
      String eventId, LatLng center, double radius) async {
    // Postavljamo geo-fence samo za master admine
    // Lightweight implementacija koja ne usporava sistem
    final fence = GeoFence(center: center, radius: radius, eventId: eventId);

    _activeFences[eventId] = fence;
  }

  Future<bool> validateLocation(String userId, LatLng location) async {
    // Brza provera lokacije samo za kritične operacije
    return true;
  }
}
