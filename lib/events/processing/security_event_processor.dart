import 'dart:async';

import 'package:injectable/injectable.dart';
import '../../core/interfaces/security_event_processor.dart';
import '../../core/interfaces/logger_service_interface.dart';
import '../../core/models/event.dart';
import '../../core/models/security_status.dart';
import '../../core/models/event_processing_result.dart';

@singleton
class SecurityEventProcessor implements ISecurityEventProcessor {
  final ILoggerService _logger;
  final _eventController = StreamController<Event>.broadcast();
  final _queue = <Event>[];
  bool _isProcessing = false;
  bool _isPaused = false;

  SecurityEventProcessor(this._logger);

  @override
  Future<void> initialize() async {
    _logger.info('Initializing SecurityEventProcessor');
  }

  @override
  Stream<Event> get processedEvents => _eventController.stream;

  @override
  Future<EventProcessingResult> processEvent(Event event) async {
    try {
      if (!_validateEvent(event)) {
        return EventProcessingResult(
          success: false,
          event: event,
          error: 'Invalid event type',
        );
      }

      if (_shouldQueue(event)) {
        _queue.add(event);
        return EventProcessingResult(
          success: true,
          event: event,
          metadata: {'status': 'queued'},
        );
      }

      return await _processEvent(event);
    } catch (e) {
      _logger.error('Error processing event: ${e.toString()}');
      return EventProcessingResult(
        success: false,
        event: event,
        error: e.toString(),
      );
    }
  }

  bool _validateEvent(Event event) {
    return event is SecurityEvent;
  }

  bool _shouldQueue(Event event) {
    return _isProcessing || _isPaused;
  }

  Future<EventProcessingResult> _processEvent(Event event) async {
    if (_isPaused) {
      _queue.add(event);
      return EventProcessingResult(
        success: true,
        event: event,
        metadata: {'status': 'queued'},
      );
    }

    _isProcessing = true;
    try {
      _logger.info('Processing security event: ${event.id}');
      await Future.delayed(Duration(milliseconds: 100));
      _eventController.add(event);

      return EventProcessingResult(
        success: true,
        event: event,
        metadata: {'processedAt': DateTime.now().toIso8601String()},
      );
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Future<SecurityManagerStatus> checkStatus() async {
    return SecurityManagerStatus(
      eventQueueStatus: QueueStatus(
        size: _queue.length,
        processedCount: 0,
        errorCount: 0,
        averageProcessingTime: Duration.zero,
      ),
      stateStatus: StateStatus(
        isValid: true,
        isSynchronized: true,
        lastSyncTime: DateTime.now(),
      ),
      networkStatus: NetworkStatus(
        isConnected: true,
        activeNodes: 1,
        messageQueueSize: 0,
        lastActivity: DateTime.now(),
      ),
      securityStatus: SecurityStatus(
        isActive: true,
        threatLevel: 0,
        activeThreats: [],
        lastUpdate: DateTime.now(),
      ),
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<void> synchronizeState() async {
    _logger.info('Synchronizing security event processor state');
  }

  @override
  Future<void> pause() async {
    _isPaused = true;
    _logger.info('Security event processor paused');
  }

  @override
  Future<void> resume() async {
    _isPaused = false;
    _logger.info('Security event processor resumed');
    if (!_isProcessing && _queue.isNotEmpty) {
      final event = _queue.removeAt(0);
      await processEvent(event);
    }
  }

  @override
  Future<void> clearQueue() async {
    _queue.clear();
    _logger.info('Security event processor queue cleared');
  }

  @override
  Future<void> dispose() async {
    await _eventController.close();
    _logger.info('Security event processor disposed');
  }
}
