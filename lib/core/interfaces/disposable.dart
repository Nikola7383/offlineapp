/// Interfejs za klase koje treba da oslobode resurse
abstract class Disposable {
  /// Oslobađa resurse koje klasa koristi
  Future<void> dispose();
}
