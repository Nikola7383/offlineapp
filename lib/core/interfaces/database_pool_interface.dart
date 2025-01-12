import 'base_service.dart';
import '../database/database.dart';

/// Interfejs za upravljanje pool-om database konekcija
///
/// Ovaj interfejs definiše ugovor za klase koje implementiraju connection pooling:
/// - Ograničava maksimalan broj konekcija
/// - Upravlja životnim ciklusom konekcija
/// - Obezbeđuje thread-safe pristup konekcijama
abstract class IDatabasePool implements IService, Disposable {
  /// Maksimalan broj dozvoljenih konekcija u pool-u
  static const int MAX_CONNECTIONS = 5;

  /// Izvršava operaciju sa database konekcijom
  ///
  /// [operation] je funkcija koja će biti izvršena sa dobijenom konekcijom
  /// Returns: Rezultat operacije tipa [T]
  ///
  /// Primer:
  /// ```dart
  /// final result = await pool.withConnection((db) async {
  ///   return await db.query('SELECT * FROM users');
  /// });
  /// ```
  Future<T> withConnection<T>(Future<T> Function(Database) operation);

  /// Vraća trenutni broj aktivnih konekcija u pool-u
  int get activeConnections;

  /// Vraća trenutni broj konekcija koje čekaju na oslobađanje
  int get waitingConnections;

  /// Vraća true ako je pool dostigao maksimalan broj konekcija
  bool get isFull;
}
