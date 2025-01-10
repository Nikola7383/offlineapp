import 'package:collection/collection.dart';

/// Informacije o ruti između dva čvora
class RouteInfo {
  /// ID izvornog čvora
  final String sourceId;

  /// ID odredišnog čvora
  final String targetId;

  /// Lista ID-eva čvorova koji čine rutu
  final List<String> path;

  /// Broj hopova na ruti
  final int hopCount;

  /// Timestamp kreiranja rute
  final DateTime timestamp;

  /// Prosečno vreme odziva rute u milisekundama
  double? avgResponseTime;

  /// Pouzdanost rute (0.0 - 1.0)
  double? reliability;

  /// Prosečno opterećenje rute (0.0 - 1.0)
  double? avgLoad;

  RouteInfo({
    required this.sourceId,
    required this.targetId,
    required this.path,
    required this.hopCount,
    required this.timestamp,
    this.avgResponseTime,
    this.reliability,
    this.avgLoad,
  });

  /// Kreira kopiju sa ažuriranim vrednostima
  RouteInfo copyWith({
    List<String>? path,
    int? hopCount,
    DateTime? timestamp,
    double? avgResponseTime,
    double? reliability,
    double? avgLoad,
  }) {
    return RouteInfo(
      sourceId: sourceId,
      targetId: targetId,
      path: path ?? List.from(this.path),
      hopCount: hopCount ?? this.hopCount,
      timestamp: timestamp ?? this.timestamp,
      avgResponseTime: avgResponseTime ?? this.avgResponseTime,
      reliability: reliability ?? this.reliability,
      avgLoad: avgLoad ?? this.avgLoad,
    );
  }

  /// Proverava da li je ruta zastarela
  bool isStale(Duration threshold) =>
      DateTime.now().difference(timestamp) > threshold;

  /// Računa kompozitni skor rute
  double calculateScore() {
    var score = 0.0;
    var weightSum = 0.0;

    // Težinski faktori
    const hopWeight = 0.3;
    const responseWeight = 0.3;
    const reliabilityWeight = 0.2;
    const loadWeight = 0.2;

    // Hop skor (manji broj hopova = bolji skor)
    final hopScore = 1.0 / (hopCount + 1);
    score += hopScore * hopWeight;
    weightSum += hopWeight;

    // Response time skor
    if (avgResponseTime != null) {
      final responseScore = 1.0 / (1.0 + avgResponseTime! / 1000.0);
      score += responseScore * responseWeight;
      weightSum += responseWeight;
    }

    // Reliability skor
    if (reliability != null) {
      score += reliability! * reliabilityWeight;
      weightSum += reliabilityWeight;
    }

    // Load skor
    if (avgLoad != null) {
      score += (1.0 - avgLoad!) * loadWeight;
      weightSum += loadWeight;
    }

    // Normalizuj skor
    return weightSum > 0 ? score / weightSum : 0.0;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteInfo &&
          runtimeType == other.runtimeType &&
          sourceId == other.sourceId &&
          targetId == other.targetId &&
          hopCount == other.hopCount;

  @override
  int get hashCode => sourceId.hashCode ^ targetId.hashCode ^ hopCount.hashCode;

  @override
  String toString() {
    return 'RouteInfo('
        'source: $sourceId, '
        'target: $targetId, '
        'hops: $hopCount, '
        'path: ${path.join(" -> ")})';
  }
}
