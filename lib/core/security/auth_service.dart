import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthService {
  final DatabaseService _db;
  final LoggerService _logger;
  final SecureStorage _storage;

  AuthService({
    required DatabaseService db,
    required LoggerService logger,
    required SecureStorage storage,
  })  : _db = db,
        _logger = logger,
        _storage = storage;

  Future<User?> authenticate(String username, String password) async {
    try {
      // Hash lozinke
      final hashedPassword = _hashPassword(password);

      // Proveri lokalno
      final user = await _db.getUser(username);
      if (user == null) return null;

      if (user.passwordHash == hashedPassword) {
        // Sačuvaj sesiju
        await _storage.write(
          key: 'current_user',
          value: jsonEncode(user.toMap()),
        );
        return user;
      }

      return null;
    } catch (e) {
      _logger.error('Greška pri autentifikaciji: $e');
      return null;
    }
  }

  Future<bool> register(String username, String password, UserRole role) async {
    try {
      // Proveri da li korisnik već postoji
      if (await _db.userExists(username)) {
        return false;
      }

      // Kreiraj novog korisnika
      final user = User(
        id: const Uuid().v4(),
        username: username,
        passwordHash: _hashPassword(password),
        role: role,
        createdAt: DateTime.now(),
      );

      await _db.saveUser(user);
      return true;
    } catch (e) {
      _logger.error('Greška pri registraciji: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _storage.delete(key: 'current_user');
    } catch (e) {
      _logger.error('Greška pri odjavljivanju: $e');
    }
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
