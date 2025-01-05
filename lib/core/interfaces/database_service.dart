import '../models/result.dart';

/// Interfejs za lokalnu bazu
abstract class IDatabaseService extends IService {
  /// Čuva podatke u bazu
  Future<Result<void>> set<T>(String key, T value);

  /// Čita podatke iz baze
  Future<Result<T?>> get<T>(String key);

  /// Briše podatke iz baze
  Future<Result<void>> delete(String key);

  /// Briše sve podatke
  Future<Result<void>> clear();

  /// Vraća sve ključeve koji počinju sa prefiksom
  Future<Result<List<String>>> getKeys(String prefix);

  /// Vraća sve podatke koji počinju sa prefiksom
  Future<Result<Map<String, T>>> getAll<T>(String prefix);

  /// Batch operacije
  Future<Result<void>> batch(List<BatchOperation> operations);
}
