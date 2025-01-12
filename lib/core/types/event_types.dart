/// Tipovi događaja u sistemu
enum EventType {
  /// Bezbednosni događaj (narušavanje bezbednosti, pokušaj upada)
  security,

  /// Sistemski događaj (pad sistema, preopterećenje resursa)
  system,

  /// Korisnički događaj (prijava, odjava, izmena podataka)
  user,

  /// Mrežni događaj (prekid konekcije, problem sa sinhronizacijom)
  network,

  /// Događaj vezan za podatke (gubitak podataka, korupcija)
  data,

  /// Događaj vezan za hardver (kvar komponente, pregrevanje)
  hardware
}

/// Prioritet događaja
enum EventPriority {
  /// Kritičan - zahteva momentalnu reakciju
  critical,

  /// Visok - zahteva brzu reakciju
  high,

  /// Srednji - zahteva pažnju ali nije urgentan
  medium,

  /// Nizak - rutinski događaj
  low
}

/// Predstavlja događaj u sistemu
class Event {
  final String id;
  final EventType type;
  final EventPriority priority;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const Event({
    required this.id,
    required this.type,
    required this.priority,
    required this.description,
    required this.timestamp,
    this.metadata,
  });
}
