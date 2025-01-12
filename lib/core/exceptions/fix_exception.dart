class FixException implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  FixException(
    this.message, {
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() =>
      'FixException: $message${originalError != null ? '\nOriginal error: $originalError' : ''}';
}
