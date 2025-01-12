class ExponentialBackoff {
  final int initialDelayMs;
  final int maxDelayMs;
  final double multiplier;

  ExponentialBackoff({
    this.initialDelayMs = 100,
    this.maxDelayMs = 10000,
    this.multiplier = 2.0,
  });

  Duration getDelay(int attempt) {
    final delay = (initialDelayMs * (multiplier * attempt)).toInt();
    return Duration(milliseconds: delay.clamp(initialDelayMs, maxDelayMs));
  }
}
