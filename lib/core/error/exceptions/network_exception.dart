class NetworkException implements Exception {
  final String message;
  final int statusCode;
  final String endpoint;

  NetworkException(
    this.message, {
    required this.statusCode,
    required this.endpoint,
  });

  @override
  String toString() =>
      'NetworkException: $message (Status: $statusCode, Endpoint: $endpoint)';
}
