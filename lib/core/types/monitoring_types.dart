/// Tipovi za monitoring i dijagnostiku sistema

/// Status zdravlja komponente ili sistema
enum HealthStatus {
  healthy, // Sistem radi normalno
  warning, // Postoje upozorenja ali sistem i dalje funkcioniše
  critical, // Kritični problemi koji zahtevaju hitnu intervenciju
  unknown // Status nije moguće utvrditi
}

/// Tip dijagnostičkog događaja
enum DiagnosticEventType {
  systemCheck, // Redovna provera sistema
  performanceIssue, // Problem sa performansama
  securityAlert, // Bezbednosno upozorenje
  resourceWarning, // Upozorenje o resursima
  componentFailure // Otkazivanje komponente
}

/// Rezultat provere zdravlja sistema
class HealthCheck {
  final DateTime timestamp;
  final HealthStatus status;
  final String message;
  final Map<String, dynamic>? details;

  const HealthCheck({
    required this.timestamp,
    required this.status,
    required this.message,
    this.details,
  });
}

/// Dijagnostički događaj u sistemu
class DiagnosticEvent {
  final DateTime timestamp;
  final DiagnosticEventType type;
  final String description;
  final Map<String, dynamic>? metadata;

  const DiagnosticEvent({
    required this.timestamp,
    required this.type,
    required this.description,
    this.metadata,
  });
}
