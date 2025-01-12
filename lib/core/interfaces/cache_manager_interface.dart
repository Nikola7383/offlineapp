import 'base_service.dart';

/// Interfejs za upravljanje kešom
abstract class ICacheManager implements IService {
  /// Postavlja vrednost u keš
  Future<void> set(String key, dynamic value, {Duration? expiry});

  /// Vraća vrednost iz keša
  Future<dynamic> get(String key);

  /// Proverava da li postoji vrednost u kešu
  Future<bool> has(String key);

  /// Briše vrednost iz keša
  Future<void> remove(String key);

  /// Briše sve vrednosti iz keša
  Future<void> clear();

  /// Vraća sve ključeve iz keša
  Future<List<String>> keys();

  /// Vraća veličinu keša
  Future<int> size();

  /// Proverava da li je vrednost istekla
  Future<bool> isExpired(String key);

  /// Čisti istekle vrednosti iz keša
  Future<void> cleanExpired();
}
