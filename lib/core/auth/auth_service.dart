import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../logging/logger_service.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthService {
  final LoggerService logger;
  final FlutterSecureStorage _storage;

  User? _currentUser;

  AuthService({
    required this.logger,
  }) : _storage = const FlutterSecureStorage();

  User? get currentUser => _currentUser;

  Future<bool> initialize() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token != null) {
        _currentUser = await _getUserFromToken(token);
        return true;
      }
      return false;
    } catch (e) {
      logger.error('Failed to initialize auth service', e);
      return false;
    }
  }

  Future<AuthResult> login(String username, String password) async {
    try {
      // Hash password
      final hashedPassword = _hashPassword(password);

      // TODO: Implement actual API call
      if (username == 'test' && hashedPassword.isNotEmpty) {
        final user = User(
          id: 'user_1',
          username: username,
          email: 'test@example.com',
          publicKey: 'dummy_public_key',
        );

        await _storage.write(
          key: 'auth_token',
          value: 'dummy_token',
        );

        _currentUser = user;
        return AuthResult(success: true, user: user);
      }

      return AuthResult(
        success: false,
        error: 'Invalid credentials',
      );
    } catch (e) {
      logger.error('Login failed', e);
      return AuthResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> logout() async {
    try {
      await _storage.delete(key: 'auth_token');
      _currentUser = null;
      return true;
    } catch (e) {
      logger.error('Logout failed', e);
      return false;
    }
  }

  Future<User?> _getUserFromToken(String token) async {
    // TODO: Implement actual token validation and user retrieval
    return User(
      id: 'user_1',
      username: 'test',
      email: 'test@example.com',
      publicKey: 'dummy_public_key',
    );
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }
}

class User {
  final String id;
  final String username;
  final String email;
  final String publicKey;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.publicKey,
  });
}

class AuthResult {
  final bool success;
  final User? user;
  final String? error;

  AuthResult({
    required this.success,
    this.user,
    this.error,
  });
}
