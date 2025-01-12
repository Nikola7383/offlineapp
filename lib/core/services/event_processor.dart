import 'dart:async';
import 'package:injectable/injectable.dart';
import '../interfaces/event_processor_interface.dart';
import '../interfaces/logger_service.dart';
import '../models/event.dart';
import '../models/event_processing_result.dart';
import '../models/processor_status.dart';
import '../storage/secure_storage.dart';

@LazySingleton(as: IEventProcessor)
class EventProcessor implements IEventProcessor {
  final ILoggerService _logger;
  final SecureStorage _storage;
  final _eventController = StreamController<Event>.broadcast();
  ProcessorStatus _status = ProcessorStatus.initializing;
  final _processingQueue = <Event>[];
  bool _isPaused = false;

  EventProcessor(this._logger, this._storage);

  @override
  Stream<Event> get processedEvents => _eventController.stream;

  @override
  Future<void> initialize() async {
    _logger.info('Initializing EventProcessor');
    try {
      _status = ProcessorStatus.initializing;
      await _loadState();
      _status = ProcessorStatus.active;
      _logger.info('EventProcessor initialized successfully');
    } catch (e) {
      _status = ProcessorStatus.error;
      _logger.error('Failed to initialize EventProcessor: $e');
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    _logger.info('Disposing EventProcessor');
    await _eventController.close();
  }

  @override
  Future<EventProcessingResult> processEvent(Event event) async {
    if (_isPaused) {
      _logger.warning('Event processing is paused. Adding event to queue.');
      _processingQueue.add(event);
      return EventProcessingResult(
        success: false,
        message: 'Processing is paused',
        event: event,
      );
    }

    try {
      _logger.info('Processing event: ${event.id}');

      if (!await validateEvent(event)) {
        return EventProcessingResult(
          success: false,
          message: 'Event validation failed',
          event: event,
        );
      }

      final priority = await prioritizeEvent(event);
      final processedEvent = event.copyWith(
        metadata: {
          ...event.metadata,
          'processingPriority': priority,
          'processedAt': DateTime.now().toIso8601String(),
        },
        status: EventStatus.processed,
      );

      _eventController.add(processedEvent);

      return EventProcessingResult(
        success: true,
        message: 'Event processed successfully',
        event: processedEvent,
      );
    } catch (e) {
      _logger.error('Failed to process event: $e');
      return EventProcessingResult(
        success: false,
        message: 'Processing failed: $e',
        event: event,
      );
    }
  }

  @override
  Future<bool> validateEvent(Event event) async {
    _logger.info('Validating event: ${event.id}');

    if (event.id.isEmpty) {
      _logger.warning('Event validation failed: Empty ID');
      return false;
    }

    if (event.title.isEmpty) {
      _logger.warning('Event validation failed: Empty title');
      return false;
    }

    if (event.description.isEmpty) {
      _logger.warning('Event validation failed: Empty description');
      return false;
    }

    return true;
  }

  @override
  Future<int> prioritizeEvent(Event event) async {
    if (event.type == EventType.emergency) {
      return 0; // Najviši prioritet
    }

    if (event.priority == EventPriority.critical) {
      return 1;
    }

    switch (event.priority) {
      case EventPriority.high:
        return 2;
      case EventPriority.medium:
        return 3;
      case EventPriority.low:
        return 4;
      default:
        return 5;
    }
  }

  @override
  Future<List<Event>> aggregateEvents(List<Event> events) async {
    _logger.info('Aggregating ${events.length} events');

    // Grupiši događaje po tipu
    final groupedEvents = <EventType, List<Event>>{};
    for (final event in events) {
      groupedEvents.putIfAbsent(event.type, () => []).add(event);
    }

    // Kreiraj agregirane događaje
    final aggregatedEvents = <Event>[];
    for (final entry in groupedEvents.entries) {
      if (entry.value.length > 1) {
        final firstEvent = entry.value.first;
        aggregatedEvents.add(Event(
          id: 'aggregated_${firstEvent.type}_${DateTime.now().millisecondsSinceEpoch}',
          type: firstEvent.type,
          priority: firstEvent.priority,
          status: EventStatus.processed,
          title: 'Aggregated ${entry.value.length} ${firstEvent.type} events',
          description: 'Multiple events of type ${firstEvent.type} occurred',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          metadata: {
            'aggregatedCount': entry.value.length,
            'originalEventIds': entry.value.map((e) => e.id).toList(),
          },
        ));
      } else {
        aggregatedEvents.add(entry.value.first);
      }
    }

    return aggregatedEvents;
  }

  @override
  Future<List<Event>> filterEvents(
      List<Event> events, EventFilter filter) async {
    _logger.info('Filtering events with filter: $filter');

    return events.where((event) {
      if (filter.type != null && event.type != filter.type) {
        return false;
      }

      if (filter.priority != null && event.priority != filter.priority) {
        return false;
      }

      if (filter.status != null && event.status != filter.status) {
        return false;
      }

      if (filter.timePeriod != null &&
          !filter.timePeriod!.includes(event.createdAt)) {
        return false;
      }

      if (filter.isEmergency != null &&
          (event.type == EventType.emergency) != filter.isEmergency!) {
        return false;
      }

      if (filter.isSecurityRelated != null &&
          (event.type == EventType.security) != filter.isSecurityRelated!) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Future<ProcessorStatus> checkStatus() async {
    return _status;
  }

  @override
  Future<void> synchronizeState() async {
    _logger.info('Synchronizing processor state');
    _status = ProcessorStatus.synchronizing;

    try {
      // TODO: Implementirati sinhronizaciju sa drugim procesorima
      await Future.delayed(const Duration(seconds: 1));
      _status = ProcessorStatus.active;
    } catch (e) {
      _status = ProcessorStatus.error;
      _logger.error('Failed to synchronize state: $e');
      rethrow;
    }
  }

  @override
  Future<void> pause() async {
    _logger.info('Pausing event processor');
    _isPaused = true;
    _status = ProcessorStatus.paused;
  }

  @override
  Future<void> resume() async {
    _logger.info('Resuming event processor');
    _isPaused = false;
    _status = ProcessorStatus.active;

    // Procesiraj događaje koji su na čekanju
    while (_processingQueue.isNotEmpty) {
      final event = _processingQueue.removeAt(0);
      await processEvent(event);
    }
  }

  @override
  Future<void> clearQueue() async {
    _logger.info('Clearing processing queue');
    _processingQueue.clear();
  }

  Future<void> _loadState() async {
    // TODO: Implementirati učitavanje stanja iz storage-a
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
