import 'dart:async';
import 'package:injectable/injectable.dart';
import '../core/interfaces/logger_service_interface.dart';
import '../core/interfaces/access_control_interface.dart';
import '../models/access_control_types.dart';

@singleton
class AccessControlManager implements IAccessControlManager {
  final ILoggerService _logger;
  final _accessEventsController =
      StreamController<AccessControlEvent>.broadcast();

  bool _isInitialized = false;
  final Map<String, Set<UserRole>> _userRoles = {};
  final Map<String, Set<Permission>> _userPermissions = {};
  final List<AccessRecord> _accessHistory = [];
  final Map<String, DateTime> _accessTokens = {};

  AccessControlManager(this._logger);

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      await _logger.warning('AccessControlManager je već inicijalizovan');
      return;
    }

    await _logger.info('Inicijalizacija AccessControlManager-a');
    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    if (!_isInitialized) {
      await _logger.warning('AccessControlManager nije inicijalizovan');
      return;
    }

    await _logger.info('Gašenje AccessControlManager-a');
    await _accessEventsController.close();
    _isInitialized = false;
  }

  @override
  Future<AccessResult> checkAccess({
    required String userId,
    required ResourceType resourceType,
    required AccessOperation operation,
    Map<String, dynamic>? context,
  }) async {
    if (!_isInitialized) {
      throw StateError('AccessControlManager nije inicijalizovan');
    }

    final userRoles = _userRoles[userId] ?? {};
    final userPermissions = _userPermissions[userId] ?? {};

    // Admin ima sve dozvole
    if (userRoles.contains(UserRole.admin)) {
      final result = AccessResult(
        isAllowed: true,
        userId: userId,
        resourceType: resourceType,
        operation: operation,
        reason: 'Admin pristup',
        timestamp: DateTime.now(),
      );
      _recordAccess(result);
      return result;
    }

    // Provera dozvola
    final hasPermission = userPermissions.any((permission) =>
        permission.resourceType == resourceType &&
        permission.operations.contains(operation) &&
        (permission.expiration == null ||
            permission.expiration!.isAfter(DateTime.now())));

    final result = AccessResult(
      isAllowed: hasPermission,
      userId: userId,
      resourceType: resourceType,
      operation: operation,
      reason: hasPermission ? 'Dozvola odobrena' : 'Nedostatak dozvole',
      timestamp: DateTime.now(),
    );

    _recordAccess(result);
    return result;
  }

  @override
  Future<void> assignRole({
    required String userId,
    required UserRole role,
    String? assignedBy,
  }) async {
    if (!_isInitialized) {
      throw StateError('AccessControlManager nije inicijalizovan');
    }

    _userRoles.putIfAbsent(userId, () => {}).add(role);

    final event = AccessControlEvent.roleAssigned(
      userId: userId,
      role: role,
      timestamp: DateTime.now(),
      assignedBy: assignedBy,
    );

    _accessEventsController.add(event);
    await _logger.info('Dodeljena rola $role korisniku $userId');
  }

  @override
  Future<void> revokeRole({
    required String userId,
    required UserRole role,
    String? revokedBy,
  }) async {
    if (!_isInitialized) {
      throw StateError('AccessControlManager nije inicijalizovan');
    }

    final userRoles = _userRoles[userId];
    if (userRoles != null) {
      userRoles.remove(role);

      final event = AccessControlEvent.roleRevoked(
        userId: userId,
        role: role,
        timestamp: DateTime.now(),
        revokedBy: revokedBy,
      );

      _accessEventsController.add(event);
      await _logger.info('Uklonjena rola $role od korisnika $userId');
    }
  }

  @override
  Future<List<UserRole>> getUserRoles(String userId) async {
    if (!_isInitialized) {
      throw StateError('AccessControlManager nije inicijalizovan');
    }

    return _userRoles[userId]?.toList() ?? [];
  }

  @override
  Future<void> grantPermission({
    required String userId,
    required ResourceType resourceType,
    required Set<AccessOperation> operations,
    Duration? expiration,
  }) async {
    if (!_isInitialized) {
      throw StateError('AccessControlManager nije inicijalizovan');
    }

    final permission = Permission(
      userId: userId,
      resourceType: resourceType,
      operations: operations,
      expiration: expiration != null ? DateTime.now().add(expiration) : null,
      grantedAt: DateTime.now(),
    );

    _userPermissions.putIfAbsent(userId, () => {}).add(permission);

    final event = AccessControlEvent.permissionGranted(permission);
    _accessEventsController.add(event);

    await _logger.info(
      'Dodata dozvola za resurs $resourceType korisniku $userId',
    );
  }

  @override
  Future<void> revokePermission({
    required String userId,
    required ResourceType resourceType,
    required Set<AccessOperation> operations,
  }) async {
    if (!_isInitialized) {
      throw StateError('AccessControlManager nije inicijalizovan');
    }

    final userPermissions = _userPermissions[userId];
    if (userPermissions != null) {
      userPermissions.removeWhere(
        (permission) =>
            permission.resourceType == resourceType &&
            permission.operations.containsAll(operations),
      );

      final event = AccessControlEvent.permissionRevoked(
        userId: userId,
        resourceType: resourceType,
        operations: operations,
        timestamp: DateTime.now(),
      );

      _accessEventsController.add(event);
      await _logger.info(
        'Uklonjena dozvola za resurs $resourceType od korisnika $userId',
      );
    }
  }

  @override
  Future<bool> isInRole({
    required String userId,
    required UserRole role,
  }) async {
    if (!_isInitialized) {
      throw StateError('AccessControlManager nije inicijalizovan');
    }

    return _userRoles[userId]?.contains(role) ?? false;
  }

  @override
  Future<List<Permission>> getUserPermissions(String userId) async {
    if (!_isInitialized) {
      throw StateError('AccessControlManager nije inicijalizovan');
    }

    return _userPermissions[userId]?.toList() ?? [];
  }

  @override
  Future<List<AccessRecord>> getAccessHistory({
    required String userId,
    DateTime? from,
    DateTime? to,
    int? limit,
  }) async {
    if (!_isInitialized) {
      throw StateError('AccessControlManager nije inicijalizovan');
    }

    var records = _accessHistory
        .where((record) => record.userId == userId)
        .where((record) =>
            (from == null || record.timestamp.isAfter(from)) &&
            (to == null || record.timestamp.isBefore(to)))
        .toList();

    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (limit != null && limit > 0) {
      records = records.take(limit).toList();
    }

    return records;
  }

  @override
  Future<bool> validateAccessToken(String token) async {
    if (!_isInitialized) {
      throw StateError('AccessControlManager nije inicijalizovan');
    }

    final expiration = _accessTokens[token];
    if (expiration == null) return false;

    if (expiration.isBefore(DateTime.now())) {
      _accessTokens.remove(token);
      return false;
    }

    return true;
  }

  @override
  Future<String> generateAccessToken({
    required String userId,
    required Set<ResourceType> resources,
    required Set<AccessOperation> operations,
    Duration? expiration,
  }) async {
    if (!_isInitialized) {
      throw StateError('AccessControlManager nije inicijalizovan');
    }

    final token = DateTime.now().millisecondsSinceEpoch.toString();
    _accessTokens[token] = DateTime.now().add(expiration ?? Duration(hours: 1));

    await _logger.info('Generisan pristupni token za korisnika $userId');
    return token;
  }

  @override
  Stream<AccessControlEvent> get accessEvents => _accessEventsController.stream;

  void _recordAccess(AccessResult result) {
    final record = AccessRecord(
      userId: result.userId,
      resourceType: result.resourceType,
      operation: result.operation,
      wasAllowed: result.isAllowed,
      timestamp: result.timestamp ?? DateTime.now(),
      reason: result.reason,
    );

    _accessHistory.add(record);
    _accessEventsController.add(AccessControlEvent.accessAttempted(record));
  }
}
