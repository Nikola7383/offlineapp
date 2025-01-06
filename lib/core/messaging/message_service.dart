import '../models/message.dart';
import '../logging/logger_service.dart';
import '../security/encryption_service.dart';
import '../mesh/mesh_network.dart';
import '../auth/role_manager.dart';
import '../auth/database_service.dart';

class MessageService {
  final RoleManager _roleManager;
  final DatabaseService _db;
  final LoggerService _logger;

  MessageService({
    required RoleManager roleManager,
    required DatabaseService db,
    required LoggerService logger,
  })  : _roleManager = roleManager,
        _db = db,
        _logger = logger;

  // Slanje poruke sa proverom dozvola
  Future<bool> sendMessage(String userId, Message message) async {
    try {
      // Prvo proveravamo dozvole
      final canSend = await _roleManager.canSendMessage(userId, message);
      if (!canSend) {
        _logger.warning('Korisnik nema dozvolu za slanje ove poruke');
        return false;
      }

      // Ako ima dozvolu, šaljemo poruku
      await _db.saveMessage(message);
      return true;
    } catch (e) {
      _logger.error('Greška pri slanju poruke: $e');
      return false;
    }
  }
}
