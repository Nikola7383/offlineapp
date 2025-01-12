import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/models/event.dart';
import 'package:secure_event_app/core/services/event_service.dart';
import '../../test_helper.mocks.dart';

void main() {
  late EventService eventService;
  late MockILoggerService logger;
  late MockISecureStorage storage;

  setUp(() {
    logger = MockILoggerService();
    storage = MockISecureStorage();
    eventService = EventService(logger, storage);
  });

  group('EventService Tests', () {
    test('should initialize service', () async {
      // Arrange
      when(storage.read('events')).thenAnswer((_) async => jsonEncode([]));

      // Act
      await eventService.initialize();

      // Assert
      verify(logger.info('Initializing EventService')).called(1);
      verify(storage.read('events')).called(1);
    });

    test('should create event', () async {
      // Arrange
      final event = Event(
        id: '1',
        title: 'Test Event',
        description: 'Test Description',
        type: EventType.emergency,
        priority: EventPriority.high,
        status: EventStatus.created,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: {},
      );
      when(storage.read('events')).thenAnswer((_) async => jsonEncode([]));

      // Act
      final result = await eventService.createEvent(event);

      // Assert
      expect(result.id, event.id);
      verify(storage.write('events', any)).called(1);
      verify(logger.info('Creating new event: ${event.id}')).called(1);
    });

    test('should update event', () async {
      // Arrange
      final event = Event(
        id: '1',
        title: 'Test Event',
        description: 'Updated Description',
        type: EventType.emergency,
        priority: EventPriority.high,
        status: EventStatus.processing,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: {},
      );
      when(storage.read('events')).thenAnswer(
        (_) async => jsonEncode([event.toJson()]),
      );

      // Act
      final result = await eventService.updateEvent('1', event);

      // Assert
      expect(result.description, 'Updated Description');
      verify(storage.write('events', any)).called(1);
    });

    test('should delete event', () async {
      // Arrange
      final event = Event(
        id: '1',
        title: 'Test Event',
        description: 'Test Description',
        type: EventType.emergency,
        priority: EventPriority.high,
        status: EventStatus.created,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: {},
      );
      when(storage.read('events')).thenAnswer(
        (_) async => jsonEncode([event.toJson()]),
      );

      // Act
      await eventService.deleteEvent('1');

      // Assert
      verify(storage.write('events', jsonEncode([]))).called(1);
    });

    test('should get event by id', () async {
      // Arrange
      final event = Event(
        id: '1',
        title: 'Test Event',
        description: 'Test Description',
        type: EventType.emergency,
        priority: EventPriority.high,
        status: EventStatus.created,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: {},
      );
      when(storage.read('events')).thenAnswer(
        (_) async => jsonEncode([event.toJson()]),
      );

      // Act
      final result = await eventService.getEvent('1');

      // Assert
      expect(result?.id, '1');
      expect(result?.title, 'Test Event');
    });

    test('should get filtered events', () async {
      // Arrange
      final events = [
        Event(
          id: '1',
          title: 'Emergency Event',
          description: 'Emergency Description',
          type: EventType.emergency,
          priority: EventPriority.high,
          status: EventStatus.created,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          metadata: {},
        ),
        Event(
          id: '2',
          title: 'System Event',
          description: 'System Description',
          type: EventType.system,
          priority: EventPriority.medium,
          status: EventStatus.processing,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          metadata: {},
        ),
      ];
      when(storage.read('events')).thenAnswer(
        (_) async => jsonEncode(events.map((e) => e.toJson()).toList()),
      );

      // Act
      final result = await eventService.getEvents(
        type: EventType.emergency,
        priority: EventPriority.high,
      );

      // Assert
      expect(result.length, 1);
      expect(result.first.id, '1');
    });

    test('should archive old events', () async {
      // Arrange
      final oldEvent = Event(
        id: '1',
        title: 'Old Event',
        description: 'Old Description',
        type: EventType.system,
        priority: EventPriority.low,
        status: EventStatus.completed,
        createdAt: DateTime.now().subtract(const Duration(days: 31)),
        updatedAt: DateTime.now().subtract(const Duration(days: 31)),
        metadata: {},
      );
      final newEvent = Event(
        id: '2',
        title: 'New Event',
        description: 'New Description',
        type: EventType.system,
        priority: EventPriority.low,
        status: EventStatus.created,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: {},
      );
      when(storage.read('events')).thenAnswer(
        (_) async => jsonEncode([oldEvent.toJson(), newEvent.toJson()]),
      );

      // Act
      await eventService.archiveOldEvents(const Duration(days: 30));

      // Assert
      verify(storage.write('events', any)).called(1);
      verify(logger.info('Archiving old events')).called(1);
    });

    test('should get user events', () async {
      // Arrange
      final events = [
        Event(
          id: '1',
          title: 'User Event',
          description: 'User Description',
          type: EventType.user,
          priority: EventPriority.medium,
          status: EventStatus.created,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          metadata: {'userId': 'user1'},
        ),
        Event(
          id: '2',
          title: 'Other Event',
          description: 'Other Description',
          type: EventType.system,
          priority: EventPriority.low,
          status: EventStatus.created,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          metadata: {'userId': 'user2'},
        ),
      ];
      when(storage.read('events')).thenAnswer(
        (_) async => jsonEncode(events.map((e) => e.toJson()).toList()),
      );

      // Act
      final result = await eventService.getUserEvents('user1');

      // Assert
      expect(result.length, 1);
      expect(result.first.id, '1');
      expect(result.first.metadata['userId'], 'user1');
    });
  });
}
