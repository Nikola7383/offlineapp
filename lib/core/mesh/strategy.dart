/// Definiše različite strategije za mesh networking
enum Strategy {
  /// Zvezdasta topologija - jedan centralni čvor
  P2P_STAR,

  /// Klaster topologija - više povezanih čvorova
  P2P_CLUSTER,

  /// Point-to-point topologija - direktna veza između dva čvora
  P2P_POINT_TO_POINT
}

/// Ekstenzije za Strategy enum
extension StrategyExtension on Strategy {
  String get name {
    switch (this) {
      case Strategy.P2P_STAR:
        return 'P2P Star';
      case Strategy.P2P_CLUSTER:
        return 'P2P Cluster';
      case Strategy.P2P_POINT_TO_POINT:
        return 'P2P Point to Point';
    }
  }

  bool get supportsMultipleConnections {
    switch (this) {
      case Strategy.P2P_STAR:
      case Strategy.P2P_CLUSTER:
        return true;
      case Strategy.P2P_POINT_TO_POINT:
        return false;
    }
  }
}
