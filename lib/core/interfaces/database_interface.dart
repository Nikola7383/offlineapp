import 'base_service.dart';

/// Interfejs za rad sa bazom podataka
///
/// Definiše osnovne operacije za:
/// - Otvaranje i zatvaranje konekcije
/// - Izvršavanje upita
/// - Upravljanje transakcijama
/// - Monitoring stanja konekcije
abstract class IDatabase implements IService {
  /// Vraća true ako je konekcija otvorena
  bool get isOpen;

  /// Otvara konekciju ka bazi
  ///
  /// Throws [DatabaseException] ako otvaranje ne uspe
  static Future<IDatabase> open() async {
    throw UnimplementedError('Implementacija mora da obezbedi factory metodu');
  }

  /// Zatvara konekciju ka bazi
  ///
  /// Throws [DatabaseException] ako zatvaranje ne uspe
  Future<void> close();

  /// Izvršava SQL upit i vraća rezultat
  ///
  /// [query] - SQL upit koji se izvršava
  /// [params] - Parametri za upit (opciono)
  /// Returns: Rezultat upita
  ///
  /// Throws [DatabaseException] ako izvršavanje ne uspe
  Future<List<Map<String, dynamic>>> execute(
    String query, [
    Map<String, dynamic>? params,
  ]);

  /// Započinje novu transakciju
  ///
  /// Returns: [Transaction] objekat koji predstavlja transakciju
  ///
  /// Throws [DatabaseException] ako kreiranje transakcije ne uspe
  Future<Transaction> beginTransaction();

  /// Kreira praznu instancu baze za testiranje
  ///
  /// Ova metoda se koristi samo u test okruženju
  static IDatabase empty() {
    throw UnimplementedError('Implementacija mora da obezbedi factory metodu');
  }
}

/// Interfejs za rad sa transakcijama
abstract class Transaction {
  /// Potvrđuje sve promene u transakciji
  Future<void> commit();

  /// Poništava sve promene u transakciji
  Future<void> rollback();

  /// Izvršava SQL upit u kontekstu transakcije
  Future<List<Map<String, dynamic>>> execute(
    String query, [
    Map<String, dynamic>? params,
  ]);
}

/// Bazna klasa za database izuzetke
class DatabaseException implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  DatabaseException(
    this.message, {
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() =>
      'DatabaseException: $message${originalError != null ? '\nOriginal error: $originalError' : ''}';
}
