import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error, critical }

class SecureLogger {
  static final SecureLogger _instance = SecureLogger._internal();
  final List<Map<String, dynamic>> _logs = [];
  bool _initialized = false;
  final int _maxLogRetentionDays = 30;
  final int _maxLogsBeforeRotation = 10000;

  factory SecureLogger() {
    return _instance;
  }

  SecureLogger._internal();

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    debugPrint('Logger inicijalizovan');
    await _performMaintenance();
  }

  Future<void> _performMaintenance() async {
    try {
      final now = DateTime.now();
      final cutoffDate = now.subtract(Duration(days: _maxLogRetentionDays));

      _logs.removeWhere((log) {
        final logDate = DateTime.parse(log['timestamp'] as String);
        return logDate.isBefore(cutoffDate);
      });

      await _checkRotation();
    } catch (e) {
      debugPrint('Greška pri održavanju logova: $e');
    }
  }

  Future<void> _checkRotation() async {
    try {
      if (_logs.length > _maxLogsBeforeRotation) {
        await _rotateLogFile();
      }
    } catch (e) {
      debugPrint('Greška pri proveri rotacije: $e');
    }
  }

  Future<void> _rotateLogFile() async {
    try {
      // Zadržavamo samo polovinu najnovijih logova
      final keepCount = _maxLogsBeforeRotation ~/ 2;
      if (_logs.length > keepCount) {
        _logs.removeRange(0, _logs.length - keepCount);
      }
      debugPrint('Rotacija logova izvršena. Preostalo logova: ${_logs.length}');
    } catch (e) {
      debugPrint('Greška pri rotaciji logova: $e');
    }
  }

  String _calculateHash(Map<String, dynamic> logEntry) {
    final dataToHash = jsonEncode({
      'timestamp': logEntry['timestamp'],
      'level': logEntry['level'],
      'event': logEntry['event'],
      'data': logEntry['data'],
      'source': logEntry['source'],
    });

    final bytes = utf8.encode(dataToHash);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> structuredLog({
    required String event,
    required LogLevel level,
    required Map<String, dynamic> data,
    String? source,
    StackTrace? stackTrace,
  }) async {
    if (!_initialized) await initialize();

    try {
      final timestamp = DateTime.now().toIso8601String();
      final logEntry = {
        'timestamp': timestamp,
        'level': level.toString(),
        'event': event,
        'data': data,
        'source': source,
        'stack_trace': stackTrace?.toString(),
      };

      final hash = _calculateHash(logEntry);
      logEntry['hash'] = hash;

      _logs.add(logEntry);

      await _checkRotation();

      // Debug ispis za važne logove
      if (level == LogLevel.error || level == LogLevel.critical) {
        debugPrint('VAŽAN LOG: ${logEntry['level']} - ${logEntry['event']}');
        if (stackTrace != null) {
          debugPrint('Stack trace: $stackTrace');
        }
      } else {
        debugPrint('LOG: ${logEntry['level']} - ${logEntry['event']}');
      }
    } catch (e, stack) {
      debugPrint('Greška pri logovanju: $e');
      debugPrint(stack.toString());
    }
  }

  Future<List<Map<String, dynamic>>> queryLogs({
    DateTime? startTime,
    DateTime? endTime,
    LogLevel? level,
    String? event,
    String? source,
    int? limit,
  }) async {
    if (!_initialized) await initialize();

    try {
      var filteredLogs = _logs.where((log) {
        if (startTime != null) {
          final logTime = DateTime.parse(log['timestamp'] as String);
          if (logTime.isBefore(startTime)) return false;
        }

        if (endTime != null) {
          final logTime = DateTime.parse(log['timestamp'] as String);
          if (logTime.isAfter(endTime)) return false;
        }

        if (level != null && log['level'] != level.toString()) {
          return false;
        }

        if (event != null && !log['event'].toString().contains(event)) {
          return false;
        }

        if (source != null && log['source'] != source) {
          return false;
        }

        // Verifikacija integriteta
        final originalHash = log['hash'] as String;
        final logCopy = Map<String, dynamic>.from(log);
        logCopy.remove('hash');
        final calculatedHash = _calculateHash(logCopy);

        return originalHash == calculatedHash;
      }).toList();

      // Sortiranje po vremenu (najnoviji prvi)
      filteredLogs.sort((a, b) {
        final timeA = DateTime.parse(a['timestamp'] as String);
        final timeB = DateTime.parse(b['timestamp'] as String);
        return timeB.compareTo(timeA);
      });

      if (limit != null && filteredLogs.length > limit) {
        filteredLogs = filteredLogs.take(limit).toList();
      }

      return filteredLogs;
    } catch (e) {
      debugPrint('Greška pri čitanju logova: $e');
      return [];
    }
  }

  Future<void> clearLogs() async {
    _logs.clear();
    debugPrint('Svi logovi obrisani');
  }

  Future<Map<String, dynamic>> getStatistics() async {
    if (!_initialized) await initialize();

    try {
      final now = DateTime.now();
      final last24h = now.subtract(const Duration(hours: 24));
      final lastWeek = now.subtract(const Duration(days: 7));

      int total = _logs.length;
      int last24hCount = 0;
      int lastWeekCount = 0;
      Map<String, int> levelCounts = {};
      Map<String, int> sourceCounts = {};

      for (var log in _logs) {
        final logTime = DateTime.parse(log['timestamp'] as String);
        final level = log['level'] as String;
        final source = log['source'] as String?;

        if (logTime.isAfter(last24h)) last24hCount++;
        if (logTime.isAfter(lastWeek)) lastWeekCount++;

        levelCounts[level] = (levelCounts[level] ?? 0) + 1;
        if (source != null) {
          sourceCounts[source] = (sourceCounts[source] ?? 0) + 1;
        }
      }

      return {
        'total_logs': total,
        'last_24h': last24hCount,
        'last_week': lastWeekCount,
        'by_level': levelCounts,
        'by_source': sourceCounts,
      };
    } catch (e) {
      debugPrint('Greška pri generisanju statistike: $e');
      return {};
    }
  }

  Future<void> dispose() async {
    await clearLogs();
    _initialized = false;
    debugPrint('Logger disposed');
  }
}
