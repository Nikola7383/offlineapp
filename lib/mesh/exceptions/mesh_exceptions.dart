class RouteLoopException implements Exception {
  final String message;
  RouteLoopException(this.message);
}

class NoRouteException implements Exception {
  final String message;
  NoRouteException(this.message);
}

class NoProtocolAvailableException implements Exception {
  final String message;
  NoProtocolAvailableException(this.message);
}
