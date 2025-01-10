/// Nivo prioriteta čvora
enum NodePriorityLevel { critical, high, medium, low, degraded }

/// Upravlja prioritetom čvora u mreži
class NodePriority {
  NodePriorityLevel _level;
  double _score;
  bool _canAcceptConnections;

  // Konstante za računanje skora
  static const double LOAD_WEIGHT = 0.3;
  static const double RELIABILITY_WEIGHT = 0.25;
  static const double ERROR_RATE_WEIGHT = 0.2;
  static const double BATTERY_WEIGHT = 0.15;
  static const double UPTIME_WEIGHT = 0.1;

  NodePriority._({
    required NodePriorityLevel level,
    required double score,
    bool canAcceptConnections = true,
  })  : _level = level,
        _score = score,
        _canAcceptConnections = canAcceptConnections;

  /// Kreira novi prioritet na osnovu metrika čvora
  static NodePriority calculate({
    required double load,
    required double reliability,
    required double errorRate,
    required double batteryLevel,
    required Duration uptime,
  }) {
    // Normalizuj uptime (maksimalno 24 sata)
    final normalizedUptime = uptime.inHours / 24.0;
    if (normalizedUptime > 1.0) normalizedUptime = 1.0;

    // Izračunaj kompozitni skor
    final score = (1.0 - load) * LOAD_WEIGHT +
        reliability * RELIABILITY_WEIGHT +
        (1.0 - errorRate) * ERROR_RATE_WEIGHT +
        batteryLevel * BATTERY_WEIGHT +
        normalizedUptime * UPTIME_WEIGHT;

    // Odredi nivo prioriteta na osnovu skora
    final level = _calculateLevel(score);

    return NodePriority._(
      level: level,
      score: score,
      canAcceptConnections: _canAcceptNewConnections(level, load),
    );
  }

  /// Određuje nivo prioriteta na osnovu skora
  static NodePriorityLevel _calculateLevel(double score) {
    if (score >= 0.9) return NodePriorityLevel.critical;
    if (score >= 0.75) return NodePriorityLevel.high;
    if (score >= 0.5) return NodePriorityLevel.medium;
    if (score >= 0.25) return NodePriorityLevel.low;
    return NodePriorityLevel.degraded;
  }

  /// Određuje da li čvor može prihvatiti nove konekcije
  static bool _canAcceptNewConnections(NodePriorityLevel level, double load) {
    switch (level) {
      case NodePriorityLevel.critical:
        return load < 0.7;
      case NodePriorityLevel.high:
        return load < 0.8;
      case NodePriorityLevel.medium:
        return load < 0.9;
      case NodePriorityLevel.low:
        return load < 0.95;
      case NodePriorityLevel.degraded:
        return false;
    }
  }

  /// Degradira prioritet čvora
  void degradePriority() {
    switch (_level) {
      case NodePriorityLevel.critical:
        _level = NodePriorityLevel.high;
        break;
      case NodePriorityLevel.high:
        _level = NodePriorityLevel.medium;
        break;
      case NodePriorityLevel.medium:
        _level = NodePriorityLevel.low;
        break;
      case NodePriorityLevel.low:
      case NodePriorityLevel.degraded:
        _level = NodePriorityLevel.degraded;
        break;
    }
    _updateAcceptanceStatus();
  }

  /// Unapređuje prioritet čvora
  void upgradePriority() {
    switch (_level) {
      case NodePriorityLevel.degraded:
        _level = NodePriorityLevel.low;
        break;
      case NodePriorityLevel.low:
        _level = NodePriorityLevel.medium;
        break;
      case NodePriorityLevel.medium:
        _level = NodePriorityLevel.high;
        break;
      case NodePriorityLevel.high:
      case NodePriorityLevel.critical:
        _level = NodePriorityLevel.critical;
        break;
    }
    _updateAcceptanceStatus();
  }

  /// Ažurira status prihvatanja konekcija
  void _updateAcceptanceStatus() {
    _canAcceptConnections = _level != NodePriorityLevel.degraded;
  }

  /// Vraća skor za redistribuciju
  double get redistributionScore {
    switch (_level) {
      case NodePriorityLevel.critical:
        return 1.0;
      case NodePriorityLevel.high:
        return 0.8;
      case NodePriorityLevel.medium:
        return 0.6;
      case NodePriorityLevel.low:
        return 0.4;
      case NodePriorityLevel.degraded:
        return 0.0;
    }
  }

  NodePriorityLevel get level => _level;
  double get score => _score;
  bool get canAcceptConnections => _canAcceptConnections;

  @override
  String toString() => 'NodePriority(level: $_level, score: $_score)';
}
