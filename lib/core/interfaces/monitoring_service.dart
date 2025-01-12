import 'base_service.dart';

/// Interfejs za monitoring servis
abstract class IMonitoringService implements IAsyncService {
  /// Beleži metriku
  Future<void> recordMetric(Metric metric);

  /// Beleži health check
  Future<void> recordHealthCheck(HealthCheck check);

  /// Vraća metrike za dati period
  Future<List<Metric>> getMetrics({
    String? name,
    DateTime? from,
    DateTime? to,
    int? limit,
  });

  /// Vraća health checkove za dati period
  Future<List<HealthCheck>> getHealthChecks({
    String? serviceName,
    DateTime? from,
    DateTime? to,
    int? limit,
  });

  /// Stream za praćenje metrika u realnom vremenu
  Stream<Metric> get metricStream;

  /// Stream za praćenje health checkova u realnom vremenu
  Stream<HealthCheck> get healthStream;
}

/// Interfejs za dijagnostiku
abstract class IDiagnosticsService implements IAsyncService {
  /// Prikuplja dijagnostičke podatke
  Future<DiagnosticReport> collectDiagnostics();

  /// Vraća istoriju dijagnostičkih izveštaja
  Future<List<DiagnosticReport>> getHistory({
    DateTime? from,
    DateTime? to,
    int? limit,
  });

  /// Briše istoriju dijagnostike
  Future<void> clearHistory({DateTime? before});

  /// Stream za praćenje dijagnostičkih događaja
  Stream<DiagnosticEvent> get diagnosticStream;
}

/// Metrika
class Metric {
  /// Ime metrike
  final String name;

  /// Vrednost
  final double value;

  /// Jedinica mere
  final String unit;

  /// Vreme merenja
  final DateTime timestamp;

  /// Tagovi
  final Map<String, String> tags;

  /// Metadata
  final Map<String, dynamic> metadata;

  /// Kreira novu metriku
  Metric({
    required this.name,
    required this.value,
    required this.unit,
    required this.timestamp,
    this.tags = const {},
    this.metadata = const {},
  });
}

/// Health check
class HealthCheck {
  /// Ime servisa
  final String serviceName;

  /// Status
  final HealthStatus status;

  /// Detalji
  final String details;

  /// Vreme provere
  final DateTime timestamp;

  /// Trajanje provere
  final Duration duration;

  /// Metadata
  final Map<String, dynamic> metadata;

  /// Kreira novi health check
  HealthCheck({
    required this.serviceName,
    required this.status,
    required this.details,
    required this.timestamp,
    required this.duration,
    this.metadata = const {},
  });
}

/// Dijagnostički izveštaj
class DiagnosticReport {
  /// ID izveštaja
  final String id;

  /// Vreme kreiranja
  final DateTime timestamp;

  /// Sistemske informacije
  final SystemInfo systemInfo;

  /// Performanse
  final PerformanceMetrics performance;

  /// Greške
  final List<DiagnosticError> errors;

  /// Upozorenja
  final List<DiagnosticWarning> warnings;

  /// Metadata
  final Map<String, dynamic> metadata;

  /// Kreira novi dijagnostički izveštaj
  DiagnosticReport({
    required this.id,
    required this.timestamp,
    required this.systemInfo,
    required this.performance,
    this.errors = const [],
    this.warnings = const [],
    this.metadata = const {},
  });
}

/// Sistemske informacije
class SystemInfo {
  /// Verzija OS-a
  final String osVersion;

  /// Verzija aplikacije
  final String appVersion;

  /// Dostupna memorija
  final int availableMemory;

  /// Iskorišćenost CPU-a
  final double cpuUsage;

  /// Aktivne konekcije
  final int activeConnections;

  /// Kreira nove sistemske informacije
  SystemInfo({
    required this.osVersion,
    required this.appVersion,
    required this.availableMemory,
    required this.cpuUsage,
    required this.activeConnections,
  });
}

/// Metrike performansi
class PerformanceMetrics {
  /// Latencija (ms)
  final double latency;

  /// Throughput (req/s)
  final double throughput;

  /// Error rate (%)
  final double errorRate;

  /// Iskorišćenost resursa (%)
  final double resourceUtilization;

  /// Kreira nove metrike performansi
  PerformanceMetrics({
    required this.latency,
    required this.throughput,
    required this.errorRate,
    required this.resourceUtilization,
  });
}

/// Dijagnostička greška
class DiagnosticError {
  /// Kod greške
  final String code;

  /// Poruka
  final String message;

  /// Stack trace
  final String? stackTrace;

  /// Vreme
  final DateTime timestamp;

  /// Kreira novu dijagnostičku grešku
  DiagnosticError({
    required this.code,
    required this.message,
    this.stackTrace,
    required this.timestamp,
  });
}

/// Dijagnostičko upozorenje
class DiagnosticWarning {
  /// Kod upozorenja
  final String code;

  /// Poruka
  final String message;

  /// Vreme
  final DateTime timestamp;

  /// Kreira novo dijagnostičko upozorenje
  DiagnosticWarning({
    required this.code,
    required this.message,
    required this.timestamp,
  });
}

/// Dijagnostički događaj
class DiagnosticEvent {
  /// Tip događaja
  final DiagnosticEventType type;

  /// Poruka
  final String message;

  /// Vreme
  final DateTime timestamp;

  /// Metadata
  final Map<String, dynamic> metadata;

  /// Kreira novi dijagnostički događaj
  DiagnosticEvent({
    required this.type,
    required this.message,
    required this.timestamp,
    this.metadata = const {},
  });
}

/// Status health check-a
enum HealthStatus {
  /// Zdravo
  healthy,

  /// Degradirano
  degraded,

  /// Nezdravo
  unhealthy,

  /// Kritično
  critical
}

/// Tip dijagnostičkog događaja
enum DiagnosticEventType {
  /// Informacija
  info,

  /// Upozorenje
  warning,

  /// Greška
  error,

  /// Kritično
  critical
}
