import 'dart:convert';
import 'package:crypto/crypto.dart';

class SecureAuditLog {
  static final SecureAuditLog _instance = SecureAuditLog._internal();
  final List<AuditEntry> _logEntries = [];
  String? _previousHash;

  factory SecureAuditLog() {
    return _instance;
  }

  SecureAuditLog._internal();

  void logSecurityEvent(String eventType, Map<String, dynamic> details) {
    final entry = AuditEntry(
        timestamp: DateTime.now(),
        eventType: eventType,
        details: details,
        previousHash: _previousHash);

    _previousHash = entry.calculateHash();
    _logEntries.add(entry);
  }

  bool validateLogIntegrity() {
    String? previousHash;

    for (var entry in _logEntries) {
      if (entry.previousHash != previousHash) {
        return false;
      }
      previousHash = entry.calculateHash();
    }

    return true;
  }

  List<AuditEntry> exportSecureLogs(String adminCode) {
    if (!_validateAdminCode(adminCode)) return [];
    return List.from(_logEntries);
  }

  bool _validateAdminCode(String code) {
    // Implementacija validacije admin koda
    return true;
  }
}

class AuditEntry {
  final DateTime timestamp;
  final String eventType;
  final Map<String, dynamic> details;
  final String? previousHash;

  AuditEntry(
      {required this.timestamp,
      required this.eventType,
      required this.details,
      this.previousHash});

  String calculateHash() {
    final data = json.encode({
      'timestamp': timestamp.toIso8601String(),
      'eventType': eventType,
      'details': details,
      'previousHash': previousHash
    });

    return sha256.convert(utf8.encode(data)).toString();
  }
}
