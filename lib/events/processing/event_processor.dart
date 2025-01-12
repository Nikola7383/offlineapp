import 'dart:async';

import 'package:injectable/injectable.dart';
import '../../core/interfaces/event_processor_interface.dart';
import '../../core/models/event.dart';

@singleton
class EventProcessor implements IEventProcessor {
  final _eventController = StreamController<Event>.broadcast();
  final _queue = <Event>[];
  bool _isProcessing = false;

  @override
  Future<void> initialize() async {
    // Inicijalizacija procesora događaja
  }

  @override
  Stream<Event> get processedEvents => _eventController.stream;

  @override
  bool get isProcessing => _isProcessing;

  @override
  int get queueSize => _queue.length;

  @override
  Future<void> processEvent(Event event, int priority) async {
    event = event.copyWith(priority: priority);
    _queue.add(event);
    _queue.sort((a, b) => (b.priority ?? 0).compareTo(a.priority ?? 0));

    if (!_isProcessing) {
      await _processQueue();
    }
  }

  Future<void> _processQueue() async {
    if (_queue.isEmpty || _isProcessing) return;

    _isProcessing = true;

    while (_queue.isNotEmpty) {
      final event = _queue.removeAt(0);
      await _processEvent(event);
    }

    _isProcessing = false;
  }

  Future<void> _processEvent(Event event) async {
    try {
      // Ovde će biti implementirana stvarna logika procesiranja
      await Future.delayed(
          Duration(milliseconds: 100)); // Simulacija procesiranja
      _eventController.add(event);
    } catch (e) {
      // Ovde će biti implementirano rukovanje greškama
      rethrow;
    }
  }

  @override
  Future<void> pause() async {
    _isProcessing = false;
  }

  @override
  Future<void> resume() async {
    if (!_isProcessing && _queue.isNotEmpty) {
      await _processQueue();
    }
  }

  @override
  Future<void> clearQueue() async {
    _queue.clear();
  }

  @override
  Future<void> dispose() async {
    await _eventController.close();
  }
}
