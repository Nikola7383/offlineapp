import 'dart:async';
import 'package:injectable/injectable.dart';
import '../../core/interfaces/base_service.dart';
import '../models/critical_event.dart';

@injectable
class CriticalMonitor implements IBaseService {
  final _eventController = StreamController<CriticalEvent>.broadcast();
  final List<CriticalEvent> _recentEvents = [];
  bool _isMonitoringActive = false;
  Timer? _cleanupTimer;

  @override
  Future<void> initialize() async {
    _isMonitoringActive = false;
    _cleanupTimer = Timer.periodic(const Duration(hours: 1), (_) {
      _cleanupOldEvents();
    });
  }

  @override
  Future<void> dispose() async {
    await stopMonitoring();
    _cleanupTimer?.cancel();
    await _eventController.close();
  }

  Stream<CriticalEvent> monitorCriticalEvents() {
    if (!_isMonitoringActive) {
      throw StateError(
          'Monitoring nije aktivan. Prvo pozovite startMonitoring().');
    }
    return _eventController.stream;
  }

  Future<void> startMonitoring() async {
    if (_isMonitoringActive) return;
    _isMonitoringActive = true;
  }

  Future<void> stopMonitoring() async {
    if (!_isMonitoringActive) return;
    _isMonitoringActive = false;
  }

  Future<bool> isMonitoringActive() async {
    return _isMonitoringActive;
  }

  Future<List<CriticalEvent>> getRecentEvents() async {
    return List.unmodifiable(_recentEvents);
  }

  void _cleanupOldEvents() {
    final now = DateTime.now();
    _recentEvents.removeWhere(
      (event) => now.difference(event.timestamp).inHours > 24,
    );
  }

  void addEvent(CriticalEvent event) {
    if (!_isMonitoringActive) return;

    _recentEvents.add(event);
    _eventController.add(event);

    if (event.level == CriticalLevel.critical ||
        event.level == CriticalLevel.failure) {
      // TODO: Implementirati notifikacije za kritične događaje
    }
  }
}
