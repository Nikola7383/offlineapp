import 'package:injectable/injectable.dart';
import '../interfaces/base_service.dart';
import '../models/encrypted_message.dart';
import 'package:shared_preferences.dart';
import 'dart:convert';

/// Servis za mrežnu komunikaciju
@LazySingleton()
class NetworkService implements IAsyncService {
  final SharedPreferences _prefs;
  bool _isConnected = false;
  static const String _serverUrlKey = 'server_url';
  static const String _defaultServerUrl = 'http://localhost:8080';

  NetworkService(this._prefs);

  @override
  Future<void> initialize() async {
    // Inicijalizuj konekciju sa serverom
    await reconnect();
  }

  @override
  Future<void> dispose() async {
    _isConnected = false;
  }

  @override
  Future<void> reconnect() async {
    try {
      // TODO: Implementirati stvarnu konekciju sa serverom
      _isConnected = true;
    } catch (e) {
      _isConnected = false;
      rethrow;
    }
  }

  @override
  Future<void> pause() async {
    _isConnected = false;
  }

  @override
  Future<void> resume() async {
    await reconnect();
  }

  /// Šalje poruku na server
  Future<void> sendMessage(EncryptedMessage message) async {
    if (!_isConnected) {
      throw Exception('Nije uspostavljena konekcija sa serverom');
    }

    try {
      // TODO: Implementirati stvarno slanje poruke na server
      print('Sending message to server: ${message.id}');
    } catch (e) {
      throw Exception('Greška prilikom slanja poruke: $e');
    }
  }

  /// Dobavlja javni ključ sa servera
  Future<String?> getPublicKey(String userId) async {
    if (!_isConnected) {
      throw Exception('Nije uspostavljena konekcija sa serverom');
    }

    try {
      // TODO: Implementirati stvarno dobavljanje ključa sa servera
      return null;
    } catch (e) {
      throw Exception('Greška prilikom dobavljanja javnog ključa: $e');
    }
  }

  /// Čuva javni ključ na serveru
  Future<void> savePublicKey(String userId, String publicKey) async {
    if (!_isConnected) {
      throw Exception('Nije uspostavljena konekcija sa serverom');
    }

    try {
      // TODO: Implementirati stvarno čuvanje ključa na serveru
      print('Saving public key for user: $userId');
    } catch (e) {
      throw Exception('Greška prilikom čuvanja javnog ključa: $e');
    }
  }

  /// Vraća URL servera
  String get serverUrl => _prefs.getString(_serverUrlKey) ?? _defaultServerUrl;

  /// Postavlja URL servera
  Future<void> setServerUrl(String url) async {
    await _prefs.setString(_serverUrlKey, url);
    await reconnect();
  }

  /// Da li je povezan sa serverom
  bool get isConnected => _isConnected;
}
