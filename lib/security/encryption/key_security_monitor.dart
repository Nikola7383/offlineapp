import 'dart:async';

class KeySecurityMonitor {
  static final KeySecurityMonitor _instance = KeySecurityMonitor._internal();
  final List<String> _securityLog = [];
  final StreamController<String> _alertController =
      StreamController<String>.broadcast();

  Stream<String> get alerts => _alertController.stream;

  factory KeySecurityMonitor() {
    return _instance;
  }

  KeySecurityMonitor._internal();

  void logKeyEvent(String event) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '$timestamp: $event';
    _securityLog.add(logEntry);

    // Ako je događaj sumnjiv, šalji alert
    if (_isSuspiciousEvent(event)) {
      _alertController.add('SECURITY ALERT: $logEntry');
    }
  }

  bool _isSuspiciousEvent(String event) {
    final suspiciousPatterns = [
      'failed attempt',
      'multiple access',
      'unauthorized',
      'invalid key',
      'brute force'
    ];

    return suspiciousPatterns
        .any((pattern) => event.toLowerCase().contains(pattern));
  }

  List<String> getRecentEvents(int count) {
    return _securityLog.reversed.take(count).toList();
  }

  void clearLog() {
    _securityLog.clear();
  }

  void dispose() {
    _alertController.close();
  }
}
