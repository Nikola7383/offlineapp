enum EmergencyType {
  systemCompromise,
  networkFailure,
  dataCorruption,
  roleSystemFailure
}

enum SecurityLevel { low, medium, high, maximum }

enum RecoveryType { fullSystem, networkOnly, dataOnly }

enum ConnectionStatus { disconnected, partial, full }

enum RoutingStatus { failed, needsUpdate, optimal }

enum Severity { low, medium, high, critical }
