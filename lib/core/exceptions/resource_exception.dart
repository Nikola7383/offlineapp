class ResourceException implements Exception {
  final String message;
  ResourceException(this.message);

  @override
  String toString() => 'ResourceException: $message';
}

class ResourceExhaustedException extends ResourceException {
  ResourceExhaustedException([String message = 'Resource exhausted'])
      : super(message);
}

class ResourceNotFoundException extends ResourceException {
  ResourceNotFoundException([String message = 'Resource not found'])
      : super(message);
}

class ResourceLockedException extends ResourceException {
  ResourceLockedException([String message = 'Resource is locked'])
      : super(message);
}
