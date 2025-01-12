import 'dart:async';
import 'dart:convert';
import 'package:injectable/injectable.dart';
import '../core/interfaces/logger_service_interface.dart';
import '../core/interfaces/audit_interface.dart';
import '../models/audit_types.dart';

@singleton
class AuditManager implements IAuditManager {
  final ILoggerService _logger;
  final _auditEventsController = StreamController<AuditEvent>.broadcast();
  final _auditAlertsController = StreamController<AuditAlert>.broadcast();

  bool _isInitialized = false;
  final List<AuditEvent> _auditLog = [];
  final Map<String, AuditEventDetails> _eventDetails = {};

  AuditManager(this._logger);

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      await _logger.warning('AuditManager je već inicijalizovan');
      return;
    }

    await _logger.info('Inicijalizacija AuditManager-a');
    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    if (!_isInitialized) {
      await _logger.warning('AuditManager nije inicijalizovan');
      return;
    }

    await _logger.info('Gašenje AuditManager-a');
    await _auditEventsController.close();
    await _auditAlertsController.close();
    _isInitialized = false;
  }

  @override
  Future<void> logAuditEvent({
    required String userId,
    required AuditEventType eventType,
    required String resourceId,
    Map<String, dynamic>? metadata,
    AuditSeverity severity = AuditSeverity.info,
  }) async {
    if (!_isInitialized) {
      throw StateError('AuditManager nije inicijalizovan');
    }

    final event = AuditEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      eventType: eventType,
      resourceId: resourceId,
      timestamp: DateTime.now(),
      severity: severity,
      metadata: metadata,
    );

    _auditLog.add(event);
    _auditEventsController.add(event);

    if (severity.index >= AuditSeverity.warning.index) {
      final alert = AuditAlert(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: 'Detektovan događaj visokog prioriteta: ${eventType.name}',
        severity: severity,
        timestamp: DateTime.now(),
        affectedEventIds: [event.id],
      );
      _auditAlertsController.add(alert);
    }

    await _logger.info('Zabeležen audit događaj: ${event.id}');
  }

  @override
  Future<List<AuditEvent>> getAuditEvents({
    DateTime? from,
    DateTime? to,
    String? userId,
    String? resourceId,
    Set<AuditEventType>? eventTypes,
    Set<AuditSeverity>? severities,
    int? limit,
  }) async {
    if (!_isInitialized) {
      throw StateError('AuditManager nije inicijalizovan');
    }

    var filteredEvents = _auditLog.where((event) {
      if (from != null && event.timestamp.isBefore(from)) return false;
      if (to != null && event.timestamp.isAfter(to)) return false;
      if (userId != null && event.userId != userId) return false;
      if (resourceId != null && event.resourceId != resourceId) return false;
      if (eventTypes != null && !eventTypes.contains(event.eventType)) {
        return false;
      }
      if (severities != null && !severities.contains(event.severity)) {
        return false;
      }
      return true;
    }).toList();

    filteredEvents.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (limit != null && limit > 0) {
      filteredEvents = filteredEvents.take(limit).toList();
    }

    return filteredEvents;
  }

  @override
  Future<AuditStats> getAuditStats({
    DateTime? from,
    DateTime? to,
    String? userId,
    String? resourceId,
  }) async {
    if (!_isInitialized) {
      throw StateError('AuditManager nije inicijalizovan');
    }

    final events = await getAuditEvents(
      from: from,
      to: to,
      userId: userId,
      resourceId: resourceId,
    );

    final eventTypeCounts = <AuditEventType, int>{};
    final severityCounts = <AuditSeverity, int>{};
    final userActivityCounts = <String, int>{};
    final resourceAccessCounts = <String, int>{};

    for (final event in events) {
      eventTypeCounts[event.eventType] =
          (eventTypeCounts[event.eventType] ?? 0) + 1;
      severityCounts[event.severity] =
          (severityCounts[event.severity] ?? 0) + 1;
      userActivityCounts[event.userId] =
          (userActivityCounts[event.userId] ?? 0) + 1;
      resourceAccessCounts[event.resourceId] =
          (resourceAccessCounts[event.resourceId] ?? 0) + 1;
    }

    return AuditStats(
      totalEvents: events.length,
      eventTypeCounts: eventTypeCounts,
      severityCounts: severityCounts,
      userActivityCounts: userActivityCounts,
      resourceAccessCounts: resourceAccessCounts,
      periodStart: from ?? events.last.timestamp,
      periodEnd: to ?? events.first.timestamp,
    );
  }

  @override
  Future<int> purgeOldEvents(Duration age) async {
    if (!_isInitialized) {
      throw StateError('AuditManager nije inicijalizovan');
    }

    final threshold = DateTime.now().subtract(age);
    final initialCount = _auditLog.length;

    _auditLog.removeWhere((event) => event.timestamp.isBefore(threshold));

    final purgedCount = initialCount - _auditLog.length;
    await _logger.info('Obrisano $purgedCount starih audit događaja');

    return purgedCount;
  }

  @override
  Future<String> exportAuditLog({
    required AuditExportFormat format,
    DateTime? from,
    DateTime? to,
    String? userId,
    String? resourceId,
  }) async {
    if (!_isInitialized) {
      throw StateError('AuditManager nije inicijalizovan');
    }

    final events = await getAuditEvents(
      from: from,
      to: to,
      userId: userId,
      resourceId: resourceId,
    );

    switch (format) {
      case AuditExportFormat.json:
        return _exportToJson(events);
      case AuditExportFormat.csv:
        return _exportToCsv(events);
      case AuditExportFormat.xml:
        return _exportToXml(events);
      case AuditExportFormat.pdf:
        throw UnimplementedError('PDF export nije još implementiran');
    }
  }

  String _exportToJson(List<AuditEvent> events) {
    final List<Map<String, dynamic>> jsonList = events.map((event) {
      return {
        'id': event.id,
        'userId': event.userId,
        'eventType': event.eventType.name,
        'resourceId': event.resourceId,
        'timestamp': event.timestamp.toIso8601String(),
        'severity': event.severity.name,
        'metadata': event.metadata,
      };
    }).toList();

    return jsonEncode(jsonList);
  }

  String _exportToCsv(List<AuditEvent> events) {
    final StringBuffer csv = StringBuffer();
    csv.writeln('ID,User ID,Event Type,Resource ID,Timestamp,Severity');

    for (final event in events) {
      csv.writeln(
        '${event.id},${event.userId},${event.eventType.name},${event.resourceId},'
        '${event.timestamp.toIso8601String()},${event.severity.name}',
      );
    }

    return csv.toString();
  }

  String _exportToXml(List<AuditEvent> events) {
    final StringBuffer xml = StringBuffer();
    xml.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    xml.writeln('<auditLog>');

    for (final event in events) {
      xml.writeln('  <event>');
      xml.writeln('    <id>${event.id}</id>');
      xml.writeln('    <userId>${event.userId}</userId>');
      xml.writeln('    <eventType>${event.eventType.name}</eventType>');
      xml.writeln('    <resourceId>${event.resourceId}</resourceId>');
      xml.writeln(
          '    <timestamp>${event.timestamp.toIso8601String()}</timestamp>');
      xml.writeln('    <severity>${event.severity.name}</severity>');
      xml.writeln('  </event>');
    }

    xml.writeln('</auditLog>');
    return xml.toString();
  }

  @override
  Future<AuditVerificationResult> verifyAuditLog({
    DateTime? from,
    DateTime? to,
  }) async {
    if (!_isInitialized) {
      throw StateError('AuditManager nije inicijalizovan');
    }

    final events = await getAuditEvents(from: from, to: to);
    final invalidEventIds = <String>[];

    // Provera hronološkog redosleda
    for (var i = 1; i < events.length; i++) {
      if (events[i].timestamp.isAfter(events[i - 1].timestamp)) {
        invalidEventIds.add(events[i].id);
      }
    }

    // Provera kompletnosti podataka
    for (final event in events) {
      if (event.id.isEmpty ||
          event.userId.isEmpty ||
          event.resourceId.isEmpty ||
          event.timestamp == null) {
        invalidEventIds.add(event.id);
      }
    }

    return AuditVerificationResult(
      isValid: invalidEventIds.isEmpty,
      verifiedAt: DateTime.now(),
      eventsVerified: events.length,
      invalidEventIds: invalidEventIds.isEmpty ? null : invalidEventIds,
      failureReason: invalidEventIds.isEmpty
          ? null
          : 'Pronađeni nevažeći događaji: ${invalidEventIds.length}',
    );
  }

  @override
  Future<String> createAuditSnapshot() async {
    if (!_isInitialized) {
      throw StateError('AuditManager nije inicijalizovan');
    }

    final snapshot = {
      'timestamp': DateTime.now().toIso8601String(),
      'totalEvents': _auditLog.length,
      'events': _auditLog
          .map((e) => {
                'id': e.id,
                'userId': e.userId,
                'eventType': e.eventType.name,
                'resourceId': e.resourceId,
                'timestamp': e.timestamp.toIso8601String(),
                'severity': e.severity.name,
                'metadata': e.metadata,
              })
          .toList(),
    };

    final snapshotId = DateTime.now().millisecondsSinceEpoch.toString();
    await _logger.info('Kreiran audit snapshot: $snapshotId');

    return jsonEncode(snapshot);
  }

  @override
  Future<AuditEventDetails?> getEventDetails(String eventId) async {
    if (!_isInitialized) {
      throw StateError('AuditManager nije inicijalizovan');
    }

    final event = _auditLog.firstWhere(
      (e) => e.id == eventId,
      orElse: () => throw StateError('Događaj nije pronađen: $eventId'),
    );

    final details = _eventDetails[eventId];
    if (details != null) return details;

    // Ako detalji ne postoje, kreiramo ih
    final relatedEvents = _auditLog
        .where((e) =>
            e.userId == event.userId &&
            e.timestamp.difference(event.timestamp).abs() <=
                Duration(minutes: 5))
        .toList();

    final newDetails = AuditEventDetails(
      event: event,
      fullMetadata: event.metadata ?? {},
      relatedEvents: relatedEvents,
      contextData: {
        'userEvents': relatedEvents.length,
        'timeWindow': '5 minutes',
      },
    );

    _eventDetails[eventId] = newDetails;
    return newDetails;
  }

  @override
  Stream<AuditEvent> get auditEvents => _auditEventsController.stream;

  @override
  Stream<AuditAlert> get auditAlerts => _auditAlertsController.stream;
}
