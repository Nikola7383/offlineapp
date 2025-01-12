/// Konfiguracija za oporavak od grešaka
class RecoveryConfig {
  /// Maksimalan broj pokušaja oporavka
  static const int maxRetries = 3;

  /// Multiplikator za backoff strategiju između pokušaja
  static const int backoffMultiplier = 5;

  /// Interval za periodičnu proveru i pokušaj oporavka
  static const Duration recoveryInterval = Duration(minutes: 5);

  // Privatni konstruktor da spreči instanciranje
  RecoveryConfig._();
}
