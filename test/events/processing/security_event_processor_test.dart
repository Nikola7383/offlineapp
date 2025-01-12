import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/core/models/event.dart';
import 'package:secure_event_app/events/processing/security_event_processor.dart';

void main() {
  late SecurityEventProcessor processor;

  setUp(() {
    processor = SecurityEventProcessor();
  });

  test('inicijalizacija procesora', () async {
    await processor.initialize();
    expect(processor, isNotNull);
  });

  group('procesiranje događaja', () {
    test('uspešno procesira bezbednosni događaj', () async {
      final event = Event.security(
        id: '1',
        type: 'INTRUSION_DETECTED',
        data: {'location': 'Server Room'},
        timestamp: DateTime.now(),
        priority: 1,
        source: 'Camera 1',
        target: 'Zone A',
      );

      final result = await processor.processEvent(event);

      expect(result.success, isTrue);
      expect(result.event, equals(event));
      expect(result.metadata, isNotNull);
      expect(result.metadata!['processedAt'], isNotNull);
    });

    test('odbija neispravan tip događaja', () async {
      final event = Event.emergency(
        id: '1',
        type: 'FIRE_ALARM',
        data: {'location': 'Building A'},
        timestamp: DateTime.now(),
        priority: 1,
      );

      final result = await processor.processEvent(event);

      expect(result.success, isFalse);
      expect(result.error, contains('Nevalidan'));
    });

    test('stavlja događaj u red kada je zauzet', () async {
      final event1 = Event.security(
        id: '1',
        type: 'INTRUSION_DETECTED',
        data: {'location': 'Server Room'},
        timestamp: DateTime.now(),
        priority: 1,
      );

      final event2 = Event.security(
        id: '2',
        type: 'INTRUSION_DETECTED',
        data: {'location': 'Network Room'},
        timestamp: DateTime.now(),
        priority: 1,
      );

      // Pokrećemo prvo procesiranje
      processor.processEvent(event1);

      // Pokušavamo drugo procesiranje dok je prvo još u toku
      final result = await processor.processEvent(event2);

      expect(result.metadata?['status'], equals('queued'));
    });
  });

  group('upravljanje redom', () {
    test('pauzira i nastavlja procesiranje', () async {
      final event = Event.security(
        id: '1',
        type: 'INTRUSION_DETECTED',
        data: {'location': 'Server Room'},
        timestamp: DateTime.now(),
        priority: 1,
      );

      await processor.pause();
      final result = await processor.processEvent(event);
      expect(result.metadata?['status'], equals('queued'));

      await processor.resume();
      // Red bi trebalo da bude prazan nakon resume
      final status = await processor.checkStatus();
      expect(status.eventQueueStatus.size, equals(0));
    });

    test('čisti red', () async {
      final event = Event.security(
        id: '1',
        type: 'INTRUSION_DETECTED',
        data: {'location': 'Server Room'},
        timestamp: DateTime.now(),
        priority: 1,
      );

      await processor.pause();
      await processor.processEvent(event);
      await processor.clearQueue();

      final status = await processor.checkStatus();
      expect(status.eventQueueStatus.size, equals(0));
    });
  });

  group('stream procesiranih događaja', () {
    test('emituje procesirane događaje', () async {
      final event = Event.security(
        id: '1',
        type: 'INTRUSION_DETECTED',
        data: {'location': 'Server Room'},
        timestamp: DateTime.now(),
        priority: 1,
      );

      expectLater(
        processor.processedEvents,
        emits(event),
      );

      await processor.processEvent(event);
    });
  });

  tearDown(() async {
    await processor.dispose();
  });
}
