import 'base_service.dart';
import '../../models/audit_types.dart';

/// Interfejs za upravljanje revizijom sistema
abstract class IAuditManager implements IService {
  /// Beleži događaj revizije
  Future<void> logAuditEvent({
    required String userId,
    required AuditEventType eventType,
    required String resourceId,
    Map<String, dynamic>? metadata,
    AuditSeverity severity = AuditSeverity.info,
  });

  /// Vraća događaje revizije za određeni vremenski period
  Future<List<AuditEvent>> getAuditEvents({
    DateTime? from,
    DateTime? to,
    String? userId,
    String? resourceId,
    Set<AuditEventType>? eventTypes,
    Set<AuditSeverity>? severities,
    int? limit,
  });

  /// Vraća statistiku revizije za određeni vremenski period
  Future<AuditStats> getAuditStats({
    DateTime? from,
    DateTime? to,
    String? userId,
    String? resourceId,
  });

  /// Briše stare događaje revizije
  Future<int> purgeOldEvents(Duration age);

  /// Eksportuje događaje revizije u određenom formatu
  Future<String> exportAuditLog({
    required AuditExportFormat format,
    DateTime? from,
    DateTime? to,
    String? userId,
    String? resourceId,
  });

  /// Verifikuje integritet revizijskog loga
  Future<AuditVerificationResult> verifyAuditLog({
    DateTime? from,
    DateTime? to,
  });

  /// Kreira snapshot revizijskog loga
  Future<String> createAuditSnapshot();

  /// Vraća detalje o određenom događaju revizije
  Future<AuditEventDetails?> getEventDetails(String eventId);

  /// Stream događaja revizije
  Stream<AuditEvent> get auditEvents;

  /// Stream upozorenja revizije
  Stream<AuditAlert> get auditAlerts;
}
