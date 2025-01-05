import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/core/database/database_service.dart';

void main() {
  late DatabaseService db;

  setUp(() async {
    db = DatabaseService(logger: LoggerService());
    await db.initialize();
  });

  group('Database Performance Tests', () {
    test('Should handle bulk message inserts efficiently', () async {
      final stopwatch = Stopwatch()..start();

      // Test sa 10,000 poruka
      for (var i = 0; i < 10000; i++) {
        await db.saveMessage(Message(
          id: 'test_$i',
          content: 'Performance test message $i',
          senderId: 'sender1',
          timestamp: DateTime.now(),
        ));
      }

      stopwatch.stop();

      // Ne bi trebalo da traje duže od 5 sekundi
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    test('Should perform quick message queries', () async {
      // Priprema test podataka
      await _prepareTestData(db);

      final stopwatch = Stopwatch()..start();

      // Test pretraga
      await db.getMessages(
        since: DateTime.now().subtract(const Duration(days: 1)),
        limit: 100,
      );

      stopwatch.stop();

      // Query bi trebao biti ispod 100ms
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('Should handle concurrent operations', () async {
      final futures = <Future>[];

      // Simulira 100 konkurentnih operacija
      for (var i = 0; i < 100; i++) {
        futures.add(db.saveMessage(Message(
          id: 'concurrent_$i',
          content: 'Concurrent test $i',
          senderId: 'sender1',
          timestamp: DateTime.now(),
        )));
      }

      // Ne bi trebalo da baci exception
      await expectLater(
        Future.wait(futures),
        completes,
      );
    });
  });
}
