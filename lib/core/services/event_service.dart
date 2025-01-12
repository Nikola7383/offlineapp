import 'dart:async';
import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:secure_event_app/core/interfaces/event_service_interface.dart';
import 'package:secure_event_app/core/interfaces/logger_service.dart';
import 'package:secure_event_app/core/models/event.dart';
import 'package:secure_event_app/core/storage/secure_storage.dart';

@LazySingleton(as: IEventService)
class EventService implements IEventService {
  final ILoggerService _logger;
  final SecureStorage _storage;
  final _eventController = StreamController<Event>.broadcast();
  final String _eventsKey = 'events';
  final String _statsKey = 'event_stats';
  final String _archiveKey = 'archived_events';

  EventService(this._logger, this._storage);

  @override
  Stream<Event> get eventStream => _eventController.stream;

  @override
  Future<void> initialize() async {
    _logger.info('Initializing EventService');
    try {
      // Učitaj događaje iz storage-a
      final events = await _loadEvents();
      // Emituj sve aktivne događaje u stream
      for (var event in events) {
        if (event.status != EventStatus.archived) {
          _eventController.add(event);
        }
      }
    } catch (e) {
      _logger.error('Failed to initialize EventService: $e');
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    _logger.info('Disposing EventService');
    await _eventController.close();
  }

  @override
  Future<Event> createEvent(Event event) async {
    _logger.info('Creating new event: ${event.id}');
    try {
      final events = await _loadEvents();
      events.add(event);
      await _saveEvents(events);
      _eventController.add(event);
      return event;
    } catch (e) {
      _logger.error('Failed to create event: $e');
      rethrow;
    }
  }

  @override
  Future<Event> updateEvent(String eventId, Event event) async {
    _logger.info('Updating event: $eventId');
    try {
      final events = await _loadEvents();
      final index = events.indexWhere((e) => e.id == eventId);
      if (index == -1) {
        throw Exception('Event not found');
      }
      events[index] = event;
      await _saveEvents(events);
      _eventController.add(event);
      return event;
    } catch (e) {
      _logger.error('Failed to update event: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    _logger.info('Deleting event: $eventId');
    try {
      final events = await _loadEvents();
      events.removeWhere((e) => e.id == eventId);
      await _saveEvents(events);
    } catch (e) {
      _logger.error('Failed to delete event: $e');
      rethrow;
    }
  }

  @override
  Future<Event?> getEvent(String eventId) async {
    _logger.info('Getting event: $eventId');
    try {
      final events = await _loadEvents();
      return events.firstWhere((e) => e.id == eventId);
    } catch (e) {
      _logger.error('Failed to get event: $e');
      return null;
    }
  }

  @override
  Future<List<Event>> getEvents({
    EventType? type,
    EventPriority? priority,
    EventStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _logger.info('Getting events with filters');
    try {
      var events = await _loadEvents();

      if (type != null) {
        events = events.where((e) => e.type == type).toList();
      }
      if (priority != null) {
        events = events.where((e) => e.priority == priority).toList();
      }
      if (status != null) {
        events = events.where((e) => e.status == status).toList();
      }
      if (startDate != null) {
        events = events.where((e) => e.createdAt.isAfter(startDate)).toList();
      }
      if (endDate != null) {
        events = events.where((e) => e.createdAt.isBefore(endDate)).toList();
      }

      return events;
    } catch (e) {
      _logger.error('Failed to get events: $e');
      return [];
    }
  }

  @override
  Future<void> processEvent(String eventId) async {
    _logger.info('Processing event: $eventId');
    try {
      final event = await getEvent(eventId);
      if (event == null) {
        throw Exception('Event not found');
      }

      final updatedEvent = event.copyWith(
        status: EventStatus.processing,
        updatedAt: DateTime.now(),
      );

      await updateEvent(eventId, updatedEvent);
    } catch (e) {
      _logger.error('Failed to process event: $e');
      rethrow;
    }
  }

  @override
  Future<void> completeEvent(String eventId) async {
    _logger.info('Completing event: $eventId');
    try {
      final event = await getEvent(eventId);
      if (event == null) {
        throw Exception('Event not found');
      }

      final updatedEvent = event.copyWith(
        status: EventStatus.completed,
        updatedAt: DateTime.now(),
      );

      await updateEvent(eventId, updatedEvent);
    } catch (e) {
      _logger.error('Failed to complete event: $e');
      rethrow;
    }
  }

  @override
  Future<void> addComment(String eventId, String comment) async {
    _logger.info('Adding comment to event: $eventId');
    try {
      final event = await getEvent(eventId);
      if (event == null) {
        throw Exception('Event not found');
      }

      final comments = List<String>.from(event.metadata['comments'] ?? []);
      comments.add(comment);

      final updatedEvent = event.copyWith(
        metadata: {...event.metadata, 'comments': comments},
        updatedAt: DateTime.now(),
      );

      await updateEvent(eventId, updatedEvent);
    } catch (e) {
      _logger.error('Failed to add comment: $e');
      rethrow;
    }
  }

  @override
  Future<void> addTag(String eventId, String tag) async {
    _logger.info('Adding tag to event: $eventId');
    try {
      final event = await getEvent(eventId);
      if (event == null) {
        throw Exception('Event not found');
      }

      final tags = List<String>.from(event.metadata['tags'] ?? []);
      if (!tags.contains(tag)) {
        tags.add(tag);

        final updatedEvent = event.copyWith(
          metadata: {...event.metadata, 'tags': tags},
          updatedAt: DateTime.now(),
        );

        await updateEvent(eventId, updatedEvent);
      }
    } catch (e) {
      _logger.error('Failed to add tag: $e');
      rethrow;
    }
  }

  @override
  Future<void> archiveOldEvents(Duration olderThan) async {
    _logger.info('Archiving old events');
    try {
      final events = await _loadEvents();
      final now = DateTime.now();
      var updated = false;

      for (var i = 0; i < events.length; i++) {
        final event = events[i];
        if (now.difference(event.createdAt) > olderThan &&
            event.status != EventStatus.archived) {
          events[i] = event.copyWith(
            status: EventStatus.archived,
            updatedAt: now,
          );
          updated = true;
        }
      }

      if (updated) {
        await _saveEvents(events);
      }
    } catch (e) {
      _logger.error('Failed to archive old events: $e');
      rethrow;
    }
  }

  @override
  Future<List<Event>> getUserEvents(String userId) async {
    _logger.info('Getting events for user: $userId');
    try {
      final events = await _loadEvents();
      return events.where((e) => e.metadata['userId'] == userId).toList();
    } catch (e) {
      _logger.error('Failed to get user events: $e');
      return [];
    }
  }

  Future<List<Event>> _loadEvents() async {
    final data = await _storage.read(_eventsKey);
    if (data == null) return [];

    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => Event.fromJson(json)).toList();
  }

  Future<void> _saveEvents(List<Event> events) async {
    final jsonList = events.map((e) => e.toJson()).toList();
    await _storage.write(_eventsKey, jsonEncode(jsonList));
  }
}
