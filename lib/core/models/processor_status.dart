/// Status procesora događaja
enum ProcessorStatus {
  /// Procesor je aktivan i procesira događaje
  active,

  /// Procesor je pauziran
  paused,

  /// Procesor je u procesu inicijalizacije
  initializing,

  /// Procesor je u procesu sinhronizacije
  synchronizing,

  /// Procesor je u stanju održavanja
  maintenance,

  /// Procesor je u stanju oporavka
  recovering,

  /// Procesor je neaktivan
  inactive,

  /// Procesor je u stanju greške
  error,
}
