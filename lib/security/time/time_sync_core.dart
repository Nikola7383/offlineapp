import 'dart:async';
import 'package:ntp/ntp.dart';

class TimeSyncCore {
  static final TimeSyncCore _instance = TimeSyncCore._internal();
  DateTime? _lastSyncTime;
  Duration _timeOffset = Duration.zero;
  final List<String> _ntpServers = [
    'time.google.com',
    'pool.ntp.org',
    'time.apple.com'
  ];
  Timer? _syncTimer;
  final Duration _syncInterval = Duration(hours: 1);

  factory TimeSyncCore() {
    return _instance;
  }

  TimeSyncCore._internal() {
    _initializeTimeSync();
  }

  void _initializeTimeSync() {
    _syncTimer = Timer.periodic(_syncInterval, (timer) {
      syncTime();
    });
  }

  Future<void> syncTime() async {
    try {
      List<Duration> offsets = [];

      // Prikupljanje vremena sa više NTP servera
      for (String server in _ntpServers) {
        try {
          final DateTime ntpTime = await NTP.getNtpTime(
              lookUpAddress: server, timeout: Duration(seconds: 5));

          final offset = ntpTime.difference(DateTime.now());
          offsets.add(offset);
        } catch (e) {
          continue;
        }
      }

      if (offsets.isEmpty) {
        throw Exception('Failed to sync with any NTP server');
      }

      // Korišćenje median vrednosti za preciznije vreme
      offsets.sort();
      int middle = offsets.length ~/ 2;
      _timeOffset = offsets[middle];
      _lastSyncTime = DateTime.now();

      await SecurityCore().logSecurityEvent('TIME_SYNC', {
        'offset': _timeOffset.inMilliseconds,
        'timestamp': DateTime.now().toIso8601String()
      });
    } catch (e) {
      await SecurityCore().logSecurityEvent('TIME_SYNC_FAILED', {
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String()
      });
    }
  }

  DateTime getCurrentSecureTime() {
    return DateTime.now().add(_timeOffset);
  }

  bool isTimeSyncValid() {
    if (_lastSyncTime == null) return false;

    final timeSinceLastSync = DateTime.now().difference(_lastSyncTime!);
    return timeSinceLastSync < _syncInterval * 2;
  }

  Future<bool> validateTimeBasedOperation() async {
    if (!isTimeSyncValid()) {
      await syncTime();
      return isTimeSyncValid();
    }
    return true;
  }

  void dispose() {
    _syncTimer?.cancel();
  }
}
