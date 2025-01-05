@injectable
class NetworkResilience extends InjectableService {
  static const MAX_RETRIES = 3;
  static const BASE_DELAY = Duration(seconds: 1);

  final _backoffStrategy = ExponentialBackoff(
    initial: BASE_DELAY,
    maximum: Duration(seconds: 30),
  );

  Future<T> withResilience<T>(
    Future<T> Function() operation, {
    int maxRetries = MAX_RETRIES,
    bool shouldRetry = true,
  }) async {
    int attempts = 0;

    while (true) {
      try {
        return await operation();
      } catch (e) {
        attempts++;

        if (!shouldRetry || attempts >= maxRetries) {
          rethrow;
        }

        final delay = _backoffStrategy.getDelay(attempts);
        logger.warning(
          'Operation failed, retrying in ${delay.inSeconds}s',
          e,
        );

        await Future.delayed(delay);
      }
    }
  }
}

class ExponentialBackoff {
  final Duration initial;
  final Duration maximum;

  ExponentialBackoff({
    required this.initial,
    required this.maximum,
  });

  Duration getDelay(int attempt) {
    final delay = initial * pow(2, attempt - 1);
    return delay > maximum ? maximum : delay;
  }
}
