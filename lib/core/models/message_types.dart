/// Tipovi poruka u sistemu
enum MessageType {
  /// Tekstualna poruka
  text('text'),

  /// Broadcast poruka
  broadcast('broadcast'),

  /// Sistemska poruka
  system('system'),

  /// Poruka za sinhronizaciju keša
  cacheSync('cache_sync'),

  /// Poruka za oporavak
  recovery('recovery'),

  /// Poruka za dijagnostiku
  diagnostic('diagnostic'),

  /// Poruka za kontrolu
  control('control'),

  /// Poruka za upozorenje
  warning('warning'),

  /// Poruka za grešku
  error('error');

  final String value;
  const MessageType(this.value);
}

/// Prioriteti poruka
enum MessagePriority {
  /// Nizak prioritet
  low(0),

  /// Normalan prioritet
  normal(1),

  /// Visok prioritet
  high(2),

  /// Kritičan prioritet
  critical(3);

  final int value;
  const MessagePriority(this.value);

  factory MessagePriority.fromInt(int value) {
    return MessagePriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => MessagePriority.normal,
    );
  }

  @override
  String toString() => name;
}

/// Status transporta
enum TransportStatus {
  /// Povezan
  connected,

  /// Povezivanje u toku
  connecting,

  /// Nije povezan
  disconnected,

  /// Greška
  error
}

/// Status rute
enum RouteStatus {
  /// Aktivna
  active,

  /// Degradirana
  degraded,

  /// Neaktivna
  inactive,

  /// Greška
  error
}
