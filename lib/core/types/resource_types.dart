/// Tipovi za upravljanje resursima

/// Tip resursa koji se prati
enum ResourceType {
  memory, // Radna memorija
  storage, // Skladišni prostor
  cpu, // Procesor
  network, // Mrežni resursi
  battery // Baterija (za mobilne uređaje)
}

/// Status iskorišćenosti resursa
enum ResourceStatus {
  optimal, // Normalna upotreba
  warning, // Visoka upotreba
  critical, // Kritična upotreba
  unknown // Status nije moguće utvrditi
}

/// Predstavlja korišćenje resursa u sistemu
class ResourceUsage {
  final ResourceType type;
  final ResourceStatus status;
  final double currentUsage; // Trenutna upotreba (procenat)
  final double threshold; // Prag upozorenja (procenat)
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const ResourceUsage({
    required this.type,
    required this.status,
    required this.currentUsage,
    required this.threshold,
    required this.timestamp,
    this.metadata,
  });

  /// Proverava da li je trenutna upotreba prešla definisani prag
  bool isThresholdExceeded() => currentUsage > threshold;
}
