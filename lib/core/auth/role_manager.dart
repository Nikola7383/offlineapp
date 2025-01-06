import 'package:secure_event_app/core/storage/secure_storage.dart';
import 'package:secure_event_app/core/logging/logger_service.dart';
import 'package:secure_event_app/core/models/message.dart';
import 'package:secure_event_app/core/auth/user_role.dart';

class RoleManager {
  final SecureStorage _storage;
  final LoggerService _logger;

  RoleManager({
    required SecureStorage storage,
    required LoggerService logger,
  })  : _storage = storage,
        _logger = logger;

  Future<bool> canSendMessage(String userId, Message message) async {
    try {
      final userRole = await getUserRole(userId);
      if (userRole == null) return false;

      final restrictions = UserPermissions.restrictions[userRole];
      if (restrictions == null) return false;

      if (!restrictions.canSendText) return false;
      if (message.content.length > restrictions.maxTextLength) return false;

      if (message.hasAttachments) {
        if (!restrictions.canSendFiles) return false;
        final totalSize = message.getTotalAttachmentSize();
        if (totalSize > restrictions.maxFileSize) return false;
      }

      return true;
    } catch (e) {
      _logger.error('Greška pri proveri dozvola: $e');
      return false;
    }
  }

  Future<UserRole?> getUserRole(String userId) async {
    try {
      final roleStr = await _storage.read(key: 'user_role_$userId');
      return roleStr != null
          ? UserRole.values.firstWhere((r) => r.toString() == roleStr,
              orElse: () => UserRole.guest)
          : null;
    } catch (e) {
      _logger.error('Greška pri dohvatanju role: $e');
      return null;
    }
  }
}
