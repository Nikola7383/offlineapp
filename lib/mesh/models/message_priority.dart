/// Prioriteti poruka u mesh mreži
enum MessagePriority {
  /// Kritične poruke koje se moraju odmah obraditi
  critical,

  /// Poruke visokog prioriteta
  high,

  /// Poruke srednjeg prioriteta
  medium,

  /// Poruke niskog prioriteta
  low,
}
