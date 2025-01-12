/// Tipovi za AI servise
/// Definiše različite tipove modela koji se mogu koristiti
enum ModelType {
  /// Osnovni model za jednostavne zadatke
  basic,

  /// Napredni model za kompleksne zadatke
  advanced,

  /// Specijalizovani model za specifične domene
  specialized,

  /// Prilagođeni model za posebne potrebe
  custom
}

/// Definiše načine zaključivanja modela
enum InferenceMode {
  /// Brzo zaključivanje sa osnovnom preciznošću
  fast,

  /// Balansirano zaključivanje između brzine i preciznosti
  balanced,

  /// Precizno zaključivanje sa većim vremenom obrade
  accurate,

  /// Prilagođeno zaključivanje prema specifičnim potrebama
  custom
}

/// Definiše nivoe optimizacije za AI modele
enum OptimizationLevel {
  /// Bez optimizacije
  none,

  /// Osnovna optimizacija za poboljšanje performansi
  basic,

  /// Agresivna optimizacija za maksimalne performanse
  aggressive,

  /// Prilagođena optimizacija prema specifičnim potrebama
  custom
}

/// Definiše nivoe preciznosti za AI modele
enum AccuracyLevel {
  /// Niska preciznost, brže izvršavanje
  low,

  /// Srednja preciznost, balansirano izvršavanje
  medium,

  /// Visoka preciznost, sporije izvršavanje
  high,

  /// Maksimalna preciznost, najsporije izvršavanje
  maximum
}

/// Definiše načine obrade za AI modele
enum ProcessingMode {
  /// Sekvencijalna obrada
  sequential,

  /// Paralelna obrada
  parallel,

  /// Batch obrada
  batch,

  /// Streaming obrada
  streaming,

  /// Hibridna obrada
  hybrid
}
