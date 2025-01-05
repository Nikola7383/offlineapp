class SeedLifecycleManager {
  final Map<String, SeedStatus> _seedStatuses = {};

  Future<bool> activateSeed(String seedId, String adminId) async {
    // Seed se aktivira samo za trenutni event
    final eventInfo = await getCurrentEventInfo();

    _seedStatuses[seedId] = SeedStatus(
        activatedBy: adminId,
        activatedAt: DateTime.now(),
        eventId: eventInfo.eventId,
        validUntil: eventInfo.endTime);

    return true;
  }

  bool isSeedValidForEvent(String seedId, String eventId) {
    final status = _seedStatuses[seedId];
    if (status == null) return false;

    return status.eventId == eventId &&
        DateTime.now().isBefore(status.validUntil);
  }
}
