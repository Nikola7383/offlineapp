import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'security_types.dart';

class SecretMasterReporting {
  static const int SEVERITY_THRESHOLD = 7; // 1-10 skala
  static const int MAX_REPORT_SIZE = 10 * 1024 * 1024; // 10MB limit

  final String _masterNodeId;
  final Map<DateTime, _SecureReport> _criticalReports = {};
  bool _isMasterPresent = false;

  SecretMasterReporting(this._masterNodeId) {
    _initializeReporting();
  }

  void updateMasterPresence(bool isPresent) {
    _isMasterPresent = isPresent;
    if (isPresent) {
      _sendPendingReports();
    }
  }

  Future<void> logCriticalEvent(
    SecurityEvent event, {
    required String source,
    required Map<String, dynamic> details,
    required int severityLevel,
    List<int>? evidenceData,
  }) async {
    // Ignoriši događaje ispod praga ozbiljnosti
    if (severityLevel < SEVERITY_THRESHOLD) return;

    final report = _SecureReport(
      eventType: event,
      source: source,
      details: details,
      severityLevel: severityLevel,
      timestamp: DateTime.now(),
      evidenceHash:
          evidenceData != null ? sha256.convert(evidenceData).bytes : null,
    );

    // Sačuvaj izveštaj lokalno
    _criticalReports[report.timestamp] = report;

    // Ako je Master prisutan, odmah pošalji
    if (_isMasterPresent) {
      await _sendReport(report);
    }

    // Održavaj veličinu skladišta
    _maintainReportStorage();
  }

  Future<void> _sendReport(_SecureReport report) async {
    try {
      final formattedReport = _formatReportForHuman(report);
      final encryptedReport = await _encryptForMaster(formattedReport);

      // Pošalji preko mesh mreže
      await _sendToMaster(encryptedReport);

      // Označi kao poslato
      report.sent = true;
    } catch (e) {
      // Sačuvaj za kasnije slanje
      report.failedAttempts++;
    }
  }

  String _formatReportForHuman(_SecureReport report) {
    final buffer = StringBuffer();

    // Zaglavlje
    buffer.writeln('='.padRight(50, '='));
    buffer.writeln('KRITIČNI BEZBEDNOSNI IZVEŠTAJ');
    buffer.writeln('Vreme: ${_formatDateTime(report.timestamp)}');
    buffer.writeln('Ozbiljnost: ${_formatSeverity(report.severityLevel)}');
    buffer.writeln('='.padRight(50, '='));
    buffer.writeln();

    // Glavni detalji
    buffer.writeln('TIP DOGAĐAJA: ${_formatEventType(report.eventType)}');
    buffer.writeln('IZVOR: ${report.source}');
    buffer.writeln();

    // Detaljna analiza
    buffer.writeln('DETALJI INCIDENTA:');
    buffer.writeln('-'.padRight(30, '-'));

    for (var entry in report.details.entries) {
      buffer.writeln('${entry.key}: ${_formatDetail(entry.value)}');
    }
    buffer.writeln();

    // Dokazi
    if (report.evidenceHash != null) {
      buffer.writeln('HASH DOKAZA: ${base64.encode(report.evidenceHash!)}');
    }

    // Preporuke
    if (report.details.containsKey('recommendations')) {
      buffer.writeln();
      buffer.writeln('PREPORUČENE AKCIJE:');
      buffer.writeln('-'.padRight(30, '-'));
      for (var rec in report.details['recommendations']) {
        buffer.writeln('• $rec');
      }
    }

    return buffer.toString();
  }

  String _formatEventType(SecurityEvent event) {
    switch (event) {
      case SecurityEvent.attackDetected:
        return '🚨 DETEKTOVAN NAPAD';
      case SecurityEvent.protocolCompromised:
        return '⚠️ PROTOKOL KOMPROMITOVAN';
      case SecurityEvent.keyCompromised:
        return '🔑 KLJUČ KOMPROMITOVAN';
      case SecurityEvent.anomalyDetected:
        return '❗ KRITIČNA ANOMALIJA';
      case SecurityEvent.phoenixRegeneration:
        return '🔄 PHOENIX REGENERACIJA';
      default:
        return event.toString();
    }
  }

  String _formatSeverity(int level) {
    final indicator = '█' * level + '░' * (10 - level);
    return '[$indicator] ($level/10)';
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}.${dt.month}.${dt.year} ${dt.hour}:${dt.minute}:${dt.second}';
  }

  String _formatDetail(dynamic value) {
    if (value is Map) {
      return '\n${value.entries.map((e) => '    ${e.key}: ${e.value}').join('\n')}';
    } else if (value is List) {
      return '\n${value.map((e) => '    • $e').join('\n')}';
    }
    return value.toString();
  }

  void _maintainReportStorage() {
    // Izbaci stare izveštaje ako je prekoračen limit
    final totalSize = _calculateStorageSize();
    if (totalSize > MAX_REPORT_SIZE) {
      final sortedReports = _criticalReports.entries.toList()
        ..sort((a, b) => b.key.compareTo(a.key));

      // Zadrži samo najnovije izveštaje
      _criticalReports.clear();
      for (var entry in sortedReports.take(100)) {
        _criticalReports[entry.key] = entry.value;
      }
    }
  }

  int _calculateStorageSize() {
    return _criticalReports.values
        .map((report) => jsonEncode(report.toJson()).length)
        .fold(0, (sum, size) => sum + size);
  }
}

class _SecureReport {
  final SecurityEvent eventType;
  final String source;
  final Map<String, dynamic> details;
  final int severityLevel;
  final DateTime timestamp;
  final List<int>? evidenceHash;
  bool sent = false;
  int failedAttempts = 0;

  _SecureReport({
    required this.eventType,
    required this.source,
    required this.details,
    required this.severityLevel,
    required this.timestamp,
    this.evidenceHash,
  });

  Map<String, dynamic> toJson() => {
        'eventType': eventType.toString(),
        'source': source,
        'details': details,
        'severityLevel': severityLevel,
        'timestamp': timestamp.toIso8601String(),
        if (evidenceHash != null) 'evidenceHash': base64.encode(evidenceHash!),
      };
}
