class TimeManager {
  static final TimeManager _instance = TimeManager._internal();
  final Map<String, EventTimings> _eventTimings = {};

  factory TimeManager() {
    return _instance;
  }

  Future<void> monitorEventActivity(String eventId) async {
    final activeDevices = await _getActiveDeviceCount(eventId);

    if (_shouldDeactivateEvent(eventId, activeDevices)) {
      await _scheduleEventDeactivation(eventId);
    }
  }

  bool _shouldDeactivateEvent(String eventId, int activeDevices) {
    if (activeDevices == 0) {
      final timing = _eventTimings[eventId];
      if (timing == null) return false;

      // Čekamo 30 minuta nakon što broj uređaja padne na 0
      return DateTime.now().difference(timing.zeroDevicesTime!) >
          Duration(minutes: 30);
    }
    return false;
  }

  Future<void> _scheduleEventDeactivation(String eventId) async {
    // Implementacija deaktivacije nakon isteka vremena
  }
}
