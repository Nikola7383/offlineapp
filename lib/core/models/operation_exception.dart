class OperationException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  OperationException(this.message, {this.code, this.details});

  @override
  String toString() =>
      'OperationException: $message${code != null ? ' (code: $code)' : ''}';
}
