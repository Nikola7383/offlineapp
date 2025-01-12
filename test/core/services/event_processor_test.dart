import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/models/event.dart';
import 'package:secure_event_app/core/services/event_processor.dart';
import 'package:secure_event_app/core/interfaces/event_processor_interface.dart';
import '../../test_helper.dart';
import '../../test_helper.mocks.dart';

void main() {
  group('EventProcessor', () {
    late EventProcessor processor;
    late MockILoggerService mockLogger;

    setUp(() {
      mockLogger = MockILoggerService();
      processor = EventProcessor(mockLogger);
    });

    test('should process event successfully', () async {
      // Arrange
      final event = Event(
        id: 'test_event',
        type: EventType.system,
        priority: EventPriority.medium,
        status: EventStatus.created,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        payload: {'message': 'Test event'},
      );

      // Act
      await processor.processEvent(event);

      // Assert
      verify(mockLogger.info(any)).called(2);
    });

    test('should validate event successfully', () async {
      // Arrange
      final event = Event(
        id: 'test_event',
        type: EventType.system,
        priority: EventPriority.medium,
        status: EventStatus.created,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        payload: {'message': 'Test event'},
      );

      // Act
      final isValid = await processor.validateEvent(event);

      // Assert
      expect(isValid, isTrue);
    });

    test('should not validate event with empty id', () async {
      // Arrange
      final event = Event(
        id: '',
        type: EventType.system,
        priority: EventPriority.medium,
        status: EventStatus.created,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        payload: {'message': 'Test event'},
      );

      // Act
      final isValid = await processor.validateEvent(event);

      // Assert
      expect(isValid, isFalse);
    });

    test('should not validate event with empty payload', () async {
      // Arrange
      final event = Event(
        id: 'test_event',
        type: EventType.system,
        priority: EventPriority.medium,
        status: EventStatus.created,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        payload: {},
      );

      // Act
      final isValid = await processor.validateEvent(event);

      // Assert
      expect(isValid, isFalse);
    });

    test('should prioritize emergency event as critical', () async {
      // Arrange
      final event = Event(
        id: 'test_event',
        type: EventType.emergency,
        priority: EventPriority.medium,
        status: EventStatus.created,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        payload: {'message': 'Emergency event'},
      );

      // Act
      final priority = await processor.prioritizeEvent(event);

      // Assert
      expect(priority, equals(EventPriority.critical.index));
    });

    test('should aggregate events by type', () async {
      // Arrange
      final events = [
        Event(
          id: 'event1',
          type: EventType.system,
          priority: EventPriority.medium,
          status: EventStatus.created,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          payload: {'message': 'System event 1'},
        ),
        Event(
          id: 'event2',
          type: EventType.system,
          priority: EventPriority.medium,
          status: EventStatus.created,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          payload: {'message': 'System event 2'},
        ),
      ];

      // Act
      final aggregatedEvents = await processor.aggregateEvents(events);

      // Assert
      expect(aggregatedEvents.length, equals(events.length));
    });

    test('should filter events by type', () async {
      // Arrange
      final events = [
        Event(
          id: 'event1',
          type: EventType.system,
          priority: EventPriority.medium,
          status: EventStatus.created,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          payload: {'message': 'System event'},
        ),
        Event(
          id: 'event2',
          type: EventType.user,
          priority: EventPriority.low,
          status: EventStatus.created,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          payload: {'message': 'User event'},
        ),
      ];

      final filter = EventFilter(type: EventType.system);

      // Act
      final filteredEvents = await processor.filterEvents(events, filter);

      // Assert
      expect(filteredEvents.length, equals(1));
      expect(filteredEvents.first.type, equals(EventType.system));
    });

    test('should filter events by time period', () async {
      // Arrange
      final now = DateTime.now();
      final events = [
        Event(
          id: 'event1',
          type: EventType.system,
          priority: EventPriority.medium,
          status: EventStatus.created,
          createdAt: now.subtract(const Duration(hours: 2)),
          updatedAt: now.subtract(const Duration(hours: 2)),
          payload: {'message': 'Old event'},
        ),
        Event(
          id: 'event2',
          type: EventType.system,
          priority: EventPriority.medium,
          status: EventStatus.created,
          createdAt: now,
          updatedAt: now,
          payload: {'message': 'New event'},
        ),
      ];

      final filter = EventFilter(
        timePeriod: EventTimePeriod(
          start: now.subtract(const Duration(hours: 1)),
          end: now.add(const Duration(hours: 1)),
        ),
      );

      // Act
      final filteredEvents = await processor.filterEvents(events, filter);

      // Assert
      expect(filteredEvents.length, equals(1));
      expect(filteredEvents.first.id, equals('event2'));
    });
  });
}
