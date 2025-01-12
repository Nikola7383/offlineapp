import 'dart:async';

import 'package:injectable/injectable.dart';
import '../../core/interfaces/event_processor_interface.dart';
import '../../core/models/event.dart';

@singleton
class EventCoordinator {
  final IEventProcessor _eventProcessor;
  final _coordinationController = StreamController<Event>.broadcast();

  EventCoordinator(this._eventProcessor) {
    _eventProcessor.processedEvents.listen(_handleProcessedEvent);
  }

  Stream<Event> get coordinatedEvents => _coordinationController.stream;

  Future<void> submitEvent(Event event) async {
    final priority = _calculatePriority(event);
    await _eventProcessor.processEvent(event, priority);
  }

  int _calculatePriority(Event event) {
    // Ovde će biti implementirana logika za određivanje prioriteta
    // Trenutno vraćamo podrazumevani prioritet 1
    return event.priority ?? 1;
  }

  void _handleProcessedEvent(Event event) {
    _coordinationController.add(event);
  }

  Future<void> pauseProcessing() async {
    await _eventProcessor.pause();
  }

  Future<void> resumeProcessing() async {
    await _eventProcessor.resume();
  }

  @override
  Future<void> dispose() async {
    await _coordinationController.close();
  }
}
