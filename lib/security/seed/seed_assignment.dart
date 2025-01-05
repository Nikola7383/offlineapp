class SeedAssignment {
  static final SeedAssignment _instance = SeedAssignment._internal();
  final Map<String, SeedCredentials> _pendingAssignments = {};
  final Duration _assignmentValidityPeriod = Duration(hours: 48);

  factory SeedAssignment() {
    return _instance;
  }

  SeedAssignment._internal();

  String generateOfflineSeed(String deviceId, DateTime eventDate) {
    final credentials = SeedCredentials(
        seedCode: _generateSeedCode(),
        validFrom: eventDate,
        validUntil: eventDate.add(_assignmentValidityPeriod),
        requiresProximityValidation: true);

    _pendingAssignments[deviceId] = credentials;
    return credentials.seedCode;
  }

  bool validateSeedActivation(String deviceId, String seedCode) {
    final credentials = _pendingAssignments[deviceId];
    if (credentials == null) return false;

    final now = DateTime.now();
    if (now.isBefore(credentials.validFrom) ||
        now.isAfter(credentials.validUntil)) {
      return false;
    }

    if (credentials.requiresProximityValidation) {
      final proximityValidator = ProximityValidator();
      return proximityValidator.canOperateOffline(deviceId);
    }

    return true;
  }

  String _generateSeedCode() {
    // Implementacija generisanja jedinstvenog seed koda
    return 'SEED_${DateTime.now().millisecondsSinceEpoch}';
  }
}

class SeedCredentials {
  final String seedCode;
  final DateTime validFrom;
  final DateTime validUntil;
  final bool requiresProximityValidation;

  SeedCredentials(
      {required this.seedCode,
      required this.validFrom,
      required this.validUntil,
      required this.requiresProximityValidation});
}
