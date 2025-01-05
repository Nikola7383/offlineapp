import 'dart:async';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class SeedManagementCore {
  static final SeedManagementCore _instance = SeedManagementCore._internal();
  final Map<String, SeedDevice> _activeSeeds = {};
  final Map<String, List<String>> _adminSeeds = {}; // Admin ID -> Seed IDs
  final Duration _seedTimeout = Duration(hours: 24);

  factory SeedManagementCore() {
    return _instance;
  }

  SeedManagementCore._internal();

  Future<String> createSeed(
      {required String adminId,
      required String deviceId,
      required SeedType type,
      Duration? customTimeout}) async {
    final seedId = await _generateSeedId(deviceId);
    final seed = SeedDevice(
        id: seedId,
        deviceId: deviceId,
        adminId: adminId,
        type: type,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(customTimeout ?? _seedTimeout),
        status: SeedStatus.created);

    _activeSeeds[seedId] = seed;
    _adminSeeds.putIfAbsent(adminId, () => []).add(seedId);

    // Započni monitoring seed-a
    _startSeedMonitoring(seed);

    return seedId;
  }

  Future<String> _generateSeedId(String deviceId) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final data = utf8.encode('$deviceId:$timestamp');
    final hash = sha256.convert(data);
    return hash.toString().substring(0, 16);
  }

  void _startSeedMonitoring(SeedDevice seed) {
    Timer.periodic(Duration(minutes: 5), (timer) async {
      if (DateTime.now().isAfter(seed.expiresAt)) {
        await deactivateSeed(seed.id);
        timer.cancel();
      }
    });
  }

  Future<bool> activateSeed(String seedId, String deviceId) async {
    final seed = _activeSeeds[seedId];
    if (seed == null) return false;

    if (seed.deviceId != deviceId) return false;

    if (DateTime.now().isAfter(seed.expiresAt)) {
      await deactivateSeed(seedId);
      return false;
    }

    seed.status = SeedStatus.active;
    seed.lastActivation = DateTime.now();

    await SecurityCore().logSecurityEvent('SEED_ACTIVATION', {
      'seed_id': seedId,
      'device_id': deviceId,
      'timestamp': DateTime.now().toIso8601String()
    });

    return true;
  }

  Future<void> deactivateSeed(String seedId) async {
    final seed = _activeSeeds[seedId];
    if (seed == null) return;

    seed.status = SeedStatus.deactivated;
    _activeSeeds.remove(seedId);

    final adminSeeds = _adminSeeds[seed.adminId];
    adminSeeds?.remove(seedId);

    await SecurityCore().logSecurityEvent('SEED_DEACTIVATION', {
      'seed_id': seedId,
      'device_id': seed.deviceId,
      'timestamp': DateTime.now().toIso8601String()
    });
  }

  List<SeedDevice> getAdminSeeds(String adminId) {
    final seedIds = _adminSeeds[adminId] ?? [];
    return seedIds
        .map((id) => _activeSeeds[id])
        .where((seed) => seed != null)
        .cast<SeedDevice>()
        .toList();
  }
}

enum SeedType { regular, temporary, deception }

enum SeedStatus { created, active, deactivated }

class SeedDevice {
  final String id;
  final String deviceId;
  final String adminId;
  final SeedType type;
  final DateTime createdAt;
  final DateTime expiresAt;
  SeedStatus status;
  DateTime? lastActivation;

  SeedDevice(
      {required this.id,
      required this.deviceId,
      required this.adminId,
      required this.type,
      required this.createdAt,
      required this.expiresAt,
      required this.status});
}
