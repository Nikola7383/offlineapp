/// Tipovi za konfiguraciju i logovanje

/// Definiše izvore konfiguracije
enum ConfigSource {
  /// Konfiguracija iz fajla
  file,

  /// Konfiguracija iz okruženja
  environment,

  /// Konfiguracija iz baze podataka
  database,

  /// Konfiguracija iz memorije
  memory,

  /// Konfiguracija iz udaljenog izvora
  remote
}

/// Definiše prioritete konfiguracije
enum ConfigPriority {
  /// Nizak prioritet
  low,

  /// Srednji prioritet
  medium,

  /// Visok prioritet
  high,

  /// Kritičan prioritet
  critical
}

/// Definiše destinacije za logove
enum LogDestination {
  /// Logovanje u fajl
  file,

  /// Logovanje u konzolu
  console,

  /// Logovanje u bazu podataka
  database,

  /// Logovanje na udaljeni server
  remote,

  /// Logovanje u memoriju
  memory
}

/// Definiše periode čuvanja logova
enum LogRetention {
  /// Čuvanje jedan dan
  day,

  /// Čuvanje nedelju dana
  week,

  /// Čuvanje mesec dana
  month,

  /// Čuvanje godinu dana
  year,

  /// Neograničeno čuvanje
  unlimited
}

/// Definiše formate logova
enum LogFormat {
  /// Tekstualni format
  text,

  /// JSON format
  json,

  /// XML format
  xml,

  /// Binarni format
  binary,

  /// Prilagođeni format
  custom
}
