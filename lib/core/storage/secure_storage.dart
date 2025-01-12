import 'package:injectable/injectable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../interfaces/base_service.dart';

/// Servis za sigurno skladištenje osetljivih podataka
@lazySingleton
class SecureStorage implements IService {
  final FlutterSecureStorage _storage;

  SecureStorage() : _storage = const FlutterSecureStorage();

  @override
  Future<void> initialize() async {
    // Nema potrebe za inicijalizacijom
  }

  @override
  Future<void> dispose() async {
    // Nema potrebe za čišćenjem resursa
  }

  /// Čita vrednost za dati ključ
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  /// Upisuje vrednost za dati ključ
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Briše vrednost za dati ključ
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// Briše sve vrednosti
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  /// Vraća sve ključeve
  Future<Set<String>> getAllKeys() async {
    final all = await _storage.readAll();
    return all.keys.toSet();
  }

  /// Proverava da li postoji vrednost za dati ključ
  Future<bool> containsKey(String key) async {
    final value = await read(key);
    return value != null;
  }
}
