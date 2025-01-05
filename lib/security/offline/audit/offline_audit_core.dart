import 'package:hive/hive.dart';
import 'dart:convert';

class OfflineAuditCore {
  static final OfflineAuditCore _instance = OfflineAuditCore._internal();
  late final Box<dynamic> _auditStorage;
  final LocalEncryption _encryption = LocalEncryption();
  final int _maxAuditEntries = 10000; // Ograničenje za offline storage

  factory OfflineAuditCore() {
    return _instance;
  }

  OfflineAuditCore._internal() {
    _initializeAuditSystem();
  }

  Future<void> _initializeAuditSystem() async {
    await _setupSecureAuditStorage();
    await _validateExistingAuditLogs();
    await _setupAutoCompression();
  }

  Future<void> logAuditEvent(String eventType, Map<String, dynamic> eventData,
      AuditSeverity severity) async {
    final auditEntry = AuditEntry(
        id: _generateAuditId(),
        type: eventType,
        timestamp: DateTime.now(),
        data: eventData,
        severity: severity,
        deviceId: await _getDeviceId());

    // Enkripcija audit podataka
    final encryptedEntry = await _encryption.encryptAuditEntry(auditEntry);

    // Dodavanje hash-a za verifikaciju integriteta
    final entryHash = await _calculateEntryHash(auditEntry);

    await _auditStorage.put(auditEntry.id, {
      'data': encryptedEntry,
      'hash': entryHash,
      'timestamp': auditEntry.timestamp.millisecondsSinceEpoch
    });

    // Provera i održavanje veličine audit loga
    await _maintainAuditSize();

    // Ažuriranje audit summary-ja
    await _updateAuditSummary(auditEntry);
  }

  Future<List<AuditEntry>> queryAuditLog(
      {DateTime? startTime,
      DateTime? endTime,
      AuditSeverity? minSeverity,
      String? eventType}) async {
    List<AuditEntry> results = [];

    final entries = _auditStorage.values.where((entry) {
      if (startTime != null &&
          entry['timestamp'] < startTime.millisecondsSinceEpoch) {
        return false;
      }
      if (endTime != null &&
          entry['timestamp'] > endTime.millisecondsSinceEpoch) {
        return false;
      }
      return true;
    });

    for (var entry in entries) {
      try {
        // Verifikacija integriteta pre dekriptovanja
        if (!await _verifyEntryIntegrity(entry)) {
          await _handleAuditIntegrityViolation(entry);
          continue;
        }

        final decryptedEntry =
            await _encryption.decryptAuditEntry(entry['data']);

        if (minSeverity != null &&
            decryptedEntry.severity.index < minSeverity.index) {
          continue;
        }
        if (eventType != null && decryptedEntry.type != eventType) {
          continue;
        }

        results.add(decryptedEntry);
      } catch (e) {
        await _handleAuditDecryptionError(entry, e);
      }
    }

    return results;
  }

  Future<void> _maintainAuditSize() async {
    if (_auditStorage.length > _maxAuditEntries) {
      // Kompresija starijih zapisa
      await _compressOldEntries();

      // Brisanje najstarijih ako je i dalje potrebno
      final entriesToDelete = _auditStorage.length - _maxAuditEntries;
      if (entriesToDelete > 0) {
        final oldestEntries = _getOldestEntries(entriesToDelete);
        await _archiveAndDeleteEntries(oldestEntries);
      }
    }
  }

  Future<void> _compressOldEntries() async {
    final oldEntries = _getEntriesOlderThan(Duration(days: 7));
    for (var entry in oldEntries) {
      final compressed = await _compressEntry(entry);
      await _auditStorage.put(entry['id'], compressed);
    }
  }

  Future<Map<String, dynamic>> _compressEntry(
      Map<String, dynamic> entry) async {
    // Implementacija kompresije starijih audit zapisa
    return entry;
  }

  Future<void> _updateAuditSummary(AuditEntry entry) async {
    final summary = await _getAuditSummary();
    summary.updateWith(entry);
    await _auditStorage.put(
        'audit_summary', await _encryption.encrypt(summary));
  }
}

class AuditEntry {
  final String id;
  final String type;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  final AuditSeverity severity;
  final String deviceId;

  AuditEntry(
      {required this.id,
      required this.type,
      required this.timestamp,
      required this.data,
      required this.severity,
      required this.deviceId});
}

enum AuditSeverity { low, medium, high, critical }

class AuditSummary {
  final Map<String, int> eventCounts = {};
  final Map<AuditSeverity, int> severityCounts = {};
  DateTime lastUpdated = DateTime.now();

  void updateWith(AuditEntry entry) {
    eventCounts[entry.type] = (eventCounts[entry.type] ?? 0) + 1;
    severityCounts[entry.severity] = (severityCounts[entry.severity] ?? 0) + 1;
    lastUpdated = DateTime.now();
  }
}
