class IntegrationException implements Exception {
  final String message;
  final bool canRecover;

  IntegrationException(this.message, {required this.canRecover});

  @override
  String toString() => 'IntegrationException: $message';
}
