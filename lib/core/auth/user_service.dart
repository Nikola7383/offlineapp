class UserService {
  final SecureStorage _storage;
  final DatabaseService _db;
  final LoggerService _logger;

  UserService({
    required SecureStorage storage,
    required DatabaseService db,
    required LoggerService logger,
  })  : _storage = storage,
        _db = db,
        _logger = logger;

  // Čuvanje role korisnika
  Future<void> setUserRole(String userId, UserRole role) async {
    try {
      await _db.updateUser(userId, {'role': role.toString()});
      // Čuvamo i u secure storage za brži pristup
      await _storage.write(
        key: 'user_role_$userId',
        value: role.toString(),
      );
    } catch (e) {
      _logger.error('Greška pri postavljanju role: $e');
      rethrow;
    }
  }

  // Dohvatanje role korisnika
  Future<UserRole?> getUserRole(String userId) async {
    try {
      // Prvo probamo iz secure storage
      final roleStr = await _storage.read(key: 'user_role_$userId');
      if (roleStr != null) {
        return UserRole.values.firstWhere(
          (r) => r.toString() == roleStr,
          orElse: () => UserRole.guest,
        );
      }

      // Ako nema u storage-u, čitamo iz baze
      final user = await _db.getUser(userId);
      if (user != null) {
        final role = UserRole.values.firstWhere(
          (r) => r.toString() == user.role,
          orElse: () => UserRole.guest,
        );
        // Čuvamo u storage za sledeći put
        await _storage.write(
          key: 'user_role_$userId',
          value: role.toString(),
        );
        return role;
      }

      return UserRole.guest; // Default role
    } catch (e) {
      _logger.error('Greška pri dohvatanju role: $e');
      return UserRole.guest; // Failsafe
    }
  }
}
