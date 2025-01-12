import 'package:freezed_annotation/freezed_annotation.dart';

part 'audit_types.freezed.dart';

/// Tipovi događaja revizije
enum AuditEventType {
  login,
  logout,
  dataAccess,
  dataModification,
  configurationChange,
  securityEvent,
  systemEvent,
  userManagement,
  resourceAccess,
  resourceModification,
  emergencyAccess,
  backupOperation,
  recoveryOperation,
  maintenanceOperation,
}

/// Nivoi ozbiljnosti događaja revizije
enum AuditSeverity {
  debug,
  info,
  warning,
  error,
  critical,
}

/// Formati za eksport revizijskog loga
enum AuditExportFormat {
  json,
  csv,
  xml,
  pdf,
}

/// Događaj revizije
@freezed
class AuditEvent with _$AuditEvent {
  const factory AuditEvent({
    required String id,
    required String userId,
    required AuditEventType eventType,
    required String resourceId,
    required DateTime timestamp,
    required AuditSeverity severity,
    Map<String, dynamic>? metadata,
    String? sourceIp,
    String? userAgent,
    String? sessionId,
  }) = _AuditEvent;
}

/// Statistika revizije
@freezed
class AuditStats with _$AuditStats {
  const factory AuditStats({
    required int totalEvents,
    required Map<AuditEventType, int> eventTypeCounts,
    required Map<AuditSeverity, int> severityCounts,
    required Map<String, int> userActivityCounts,
    required Map<String, int> resourceAccessCounts,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) = _AuditStats;
}

/// Rezultat verifikacije revizijskog loga
@freezed
class AuditVerificationResult with _$AuditVerificationResult {
  const factory AuditVerificationResult({
    required bool isValid,
    required DateTime verifiedAt,
    required int eventsVerified,
    List<String>? invalidEventIds,
    String? failureReason,
  }) = _AuditVerificationResult;
}

/// Detalji događaja revizije
@freezed
class AuditEventDetails with _$AuditEventDetails {
  const factory AuditEventDetails({
    required AuditEvent event,
    required Map<String, dynamic> fullMetadata,
    List<AuditEvent>? relatedEvents,
    Map<String, dynamic>? contextData,
    String? notes,
  }) = _AuditEventDetails;
}

/// Upozorenje revizije
@freezed
class AuditAlert with _$AuditAlert {
  const factory AuditAlert({
    required String id,
    required String message,
    required AuditSeverity severity,
    required DateTime timestamp,
    required List<String> affectedEventIds,
    String? recommendation,
  }) = _AuditAlert;
}
