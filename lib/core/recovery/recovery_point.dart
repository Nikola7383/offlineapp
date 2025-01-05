class RecoveryPoint {
  final DateTime timestamp;
  final Map<String, dynamic> state;
  final String version;

  static const String CURRENT_VERSION = "1.0.0";

  RecoveryPoint({
    required this.timestamp,
    required this.state,
    this.version = CURRENT_VERSION,
  });

  // Serijalizacija trenutnog stanja
  static Future<void> save() async {
    final point = RecoveryPoint(
      timestamp: DateTime.now(),
      state: await _captureCurrentState(),
    );

    await File('recovery_point.json').writeAsString(jsonEncode(point));
  }

  // Vraćanje na prethodno stanje
  static Future<void> restore() async {
    final file = File('recovery_point.json');
    if (await file.exists()) {
      final data = jsonDecode(await file.readAsString());
      await _restoreState(data['state']);
    }
  }

  static Future<Map<String, dynamic>> _captureCurrentState() async {
    // Beležimo stanje svih kritičnih komponenti
    return {
      'database': await _captureDatabaseState(),
      'cache': await _captureCacheState(),
      'mesh': await _captureMeshState(),
      'security': await _captureSecurityState(),
    };
  }
}
