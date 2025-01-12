import 'dart:async';
import 'base_service.dart';

/// Tip resursa
enum ResourceType {
  /// CPU resurs
  cpu,

  /// Memorijski resurs
  memory,

  /// Resurs baterije
  battery,

  /// Mrežni resurs
  network,

  /// Resurs skladišta
  storage
}

/// Status resursa
enum ResourceStatus {
  /// Resurs je dostupan
  available,

  /// Resurs je zauzet
  busy,

  /// Resurs je nedostupan
  unavailable,

  /// Resurs je u kritičnom stanju
  critical,

  /// Resurs je u procesu oporavka
  recovering
}

/// Model za praćenje korišćenja resursa
class ResourceUsage {
  /// Tip resursa
  final ResourceType type;

  /// Trenutna vrednost korišćenja
  final double currentValue;

  /// Maksimalna vrednost
  final double maxValue;

  /// Status resursa
  final ResourceStatus status;

  /// Vreme merenja
  final DateTime timestamp;

  /// Metadata podaci
  final Map<String, dynamic> metadata;

  /// Kreira novi objekat za praćenje korišćenja resursa
  ResourceUsage({
    required this.type,
    required this.currentValue,
    required this.maxValue,
    required this.status,
    required this.timestamp,
    this.metadata = const {},
  });

  /// Vraća procenat iskorišćenosti
  double get usagePercentage => (currentValue / maxValue) * 100;

  /// Proverava da li je resurs preopterećen
  bool get isOverloaded => usagePercentage > 90;

  /// Proverava da li je resurs u kritičnom stanju
  bool get isCritical => status == ResourceStatus.critical;
}

/// Interfejs za upravljanje resursima
abstract class IResourceManager implements IService {
  /// Stream za praćenje korišćenja resursa
  Stream<ResourceUsage> get resourceStream;

  /// Vraća trenutno korišćenje resursa
  Future<ResourceUsage> getCurrentUsage(ResourceType type);

  /// Vraća istoriju korišćenja resursa
  Future<List<ResourceUsage>> getUsageHistory(
    ResourceType type, {
    required DateTime startTime,
    required DateTime endTime,
  });

  /// Optimizuje korišćenje resursa
  Future<void> optimizeResource(ResourceType type);

  /// Oslobađa resurs
  Future<void> releaseResource(ResourceType type);

  /// Rezerviše resurs
  Future<bool> reserveResource(
    ResourceType type, {
    required double amount,
    Duration? timeout,
  });

  /// Postavlja ograničenje za resurs
  Future<void> setResourceLimit(
    ResourceType type, {
    required double maxValue,
  });

  /// Vraća status resursa
  Future<ResourceStatus> getResourceStatus(ResourceType type);

  /// Prijavljuje problem sa resursom
  Future<void> reportResourceIssue(
    ResourceType type, {
    required String issue,
    Map<String, dynamic>? metadata,
  });
}
