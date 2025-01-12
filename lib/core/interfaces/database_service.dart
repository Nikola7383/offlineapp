import 'base_service.dart';

/// Interfejs za rad sa bazom podataka
abstract class IDatabaseService implements IAsyncService {
  /// Vraća vrednost za dati ključ
  Future<T?> get<T>(String key);

  /// Čuva vrednost za dati ključ
  Future<void> set<T>(String key, T value);

  /// Briše vrednost za dati ključ
  Future<void> delete(String key);

  /// Briše sve vrednosti
  Future<void> clear();

  /// Vraća sve ključeve
  Future<List<String>> keys();

  /// Vraća sve vrednosti
  Future<List<T>> values<T>();

  /// Izvršava batch operacije
  Future<void> batch(List<Future<void> Function()> operations);

  /// Izvršava operaciju unutar transakcije
  Future<T> transaction<T>(Future<T> Function() operation);

  /// Migrira bazu na novu verziju
  Future<void> migrate();

  /// Proverava zdravlje baze
  Future<bool> isHealthy();

  /// Registruje funkciju za deserijalizaciju tipa
  void registerDeserializer<T>(T Function(Map<String, dynamic>) fromJson);

  /// Stream za praćenje stanja konekcije
  Stream<bool> get connectionStream;
}
