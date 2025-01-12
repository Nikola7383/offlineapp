class VerificationException implements Exception {
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  VerificationException(
    this.message, {
    this.error,
    this.stackTrace,
  });

  @override
  String toString() {
    if (error != null) {
      return 'VerificationException: $message\nCaused by: $error';
    }
    return 'VerificationException: $message';
  }
}
