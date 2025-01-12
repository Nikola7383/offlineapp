import 'base_service.dart';
import '../../models/access_control_types.dart';

/// Interfejs za upravljanje kontrolom pristupa
abstract class IAccessControlManager implements IService {
  /// Proverava da li korisnik ima pristup određenom resursu
  Future<AccessResult> checkAccess({
    required String userId,
    required ResourceType resourceType,
    required AccessOperation operation,
    Map<String, dynamic>? context,
  });

  /// Dodeljuje rolu korisniku
  Future<void> assignRole({
    required String userId,
    required UserRole role,
    String? assignedBy,
  });

  /// Uklanja rolu od korisnika
  Future<void> revokeRole({
    required String userId,
    required UserRole role,
    String? revokedBy,
  });

  /// Vraća sve role korisnika
  Future<List<UserRole>> getUserRoles(String userId);

  /// Dodaje dozvolu za resurs
  Future<void> grantPermission({
    required String userId,
    required ResourceType resourceType,
    required Set<AccessOperation> operations,
    Duration? expiration,
  });

  /// Uklanja dozvolu za resurs
  Future<void> revokePermission({
    required String userId,
    required ResourceType resourceType,
    required Set<AccessOperation> operations,
  });

  /// Proverava da li je korisnik u određenoj roli
  Future<bool> isInRole({
    required String userId,
    required UserRole role,
  });

  /// Vraća sve aktivne dozvole korisnika
  Future<List<Permission>> getUserPermissions(String userId);

  /// Vraća istoriju pristupa za korisnika
  Future<List<AccessRecord>> getAccessHistory({
    required String userId,
    DateTime? from,
    DateTime? to,
    int? limit,
  });

  /// Validira token za pristup
  Future<bool> validateAccessToken(String token);

  /// Generiše novi token za pristup
  Future<String> generateAccessToken({
    required String userId,
    required Set<ResourceType> resources,
    required Set<AccessOperation> operations,
    Duration? expiration,
  });

  /// Stream događaja kontrole pristupa
  Stream<AccessControlEvent> get accessEvents;
}
