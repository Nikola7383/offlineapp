import 'package:freezed_annotation/freezed_annotation.dart';

part 'access_control_types.freezed.dart';

/// Tipovi resursa kojima se može pristupiti
enum ResourceType {
  file,
  database,
  network,
  settings,
  admin,
  security,
  emergency,
  audit,
}

/// Operacije koje se mogu izvršiti nad resursima
enum AccessOperation {
  read,
  write,
  delete,
  execute,
  modify,
  grant,
  revoke,
}

/// Role korisnika u sistemu
enum UserRole {
  admin,
  user,
  guest,
  security,
  emergency,
  audit,
}

/// Rezultat provere pristupa
@freezed
class AccessResult with _$AccessResult {
  const factory AccessResult({
    required bool isAllowed,
    required String userId,
    required ResourceType resourceType,
    required AccessOperation operation,
    String? reason,
    DateTime? timestamp,
  }) = _AccessResult;
}

/// Dozvola za pristup resursu
@freezed
class Permission with _$Permission {
  const factory Permission({
    required String userId,
    required ResourceType resourceType,
    required Set<AccessOperation> operations,
    DateTime? expiration,
    DateTime? grantedAt,
    String? grantedBy,
  }) = _Permission;
}

/// Zapis o pristupu resursu
@freezed
class AccessRecord with _$AccessRecord {
  const factory AccessRecord({
    required String userId,
    required ResourceType resourceType,
    required AccessOperation operation,
    required bool wasAllowed,
    required DateTime timestamp,
    String? reason,
    Map<String, dynamic>? context,
  }) = _AccessRecord;
}

/// Događaj kontrole pristupa
@freezed
class AccessControlEvent with _$AccessControlEvent {
  const factory AccessControlEvent.accessAttempted(AccessRecord record) =
      AccessAttempted;
  const factory AccessControlEvent.roleAssigned({
    required String userId,
    required UserRole role,
    required DateTime timestamp,
    String? assignedBy,
  }) = RoleAssigned;
  const factory AccessControlEvent.roleRevoked({
    required String userId,
    required UserRole role,
    required DateTime timestamp,
    String? revokedBy,
  }) = RoleRevoked;
  const factory AccessControlEvent.permissionGranted(Permission permission) =
      PermissionGranted;
  const factory AccessControlEvent.permissionRevoked({
    required String userId,
    required ResourceType resourceType,
    required Set<AccessOperation> operations,
    required DateTime timestamp,
  }) = PermissionRevoked;
}
