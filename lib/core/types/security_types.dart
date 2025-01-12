/// Tipovi za bezbednost

/// Definiše nivoe pristupa
enum AccessLevel {
  /// Bez pristupa
  none,

  /// Samo čitanje
  readonly,

  /// Osnovni pristup
  basic,

  /// Napredni pristup
  advanced,

  /// Administratorski pristup
  admin
}

/// Definiše nivoe revizije
enum AuditLevel {
  /// Osnovni nivo - samo kritični događaji
  basic,

  /// Srednji nivo - važni događaji
  medium,

  /// Detaljan nivo - svi događaji
  detailed,

  /// Forenzički nivo - maksimalno detaljno
  forensic
}

/// Definiše tipove bezbednosnih događaja za Bluetooth
enum BluetoothSecurityEventType {
  /// Neovlašćeni pokušaj uparivanja
  unauthorizedPairing,

  /// Detektovan sumnjiv uređaj
  suspiciousDevice,

  /// Pokušaj presretanja komunikacije
  communicationIntercept,

  /// Detektovan replay napad
  replayAttack,

  /// Narušavanje sigurnosne politike
  policyViolation
}

/// Definiše faze podizanja sistema
enum BootPhase {
  /// Inicijalna faza
  initial,

  /// Provera integriteta
  integrityCheck,

  /// Učitavanje konfiguracije
  loadingConfig,

  /// Inicijalizacija servisa
  servicesInit,

  /// Sistem spreman
  ready
}

/// Definiše nivoe bezbednosti
enum SecurityLevel {
  /// Nizak nivo bezbednosti
  low,

  /// Srednji nivo bezbednosti
  medium,

  /// Visok nivo bezbednosti
  high,

  /// Maksimalan nivo bezbednosti
  maximum
}
