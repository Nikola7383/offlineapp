import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/core/models/message.dart';
import 'package:secure_event_app/core/models/connection_models.dart';
import 'package:secure_event_app/core/services/service_locator.dart';
import 'package:secure_event_app/core/services/service_helper.dart';

void main() {
  setUp(() async {
    await ServiceLocator.instance.initialize();
  });

  tearDown(() async {
    await ServiceLocator.instance.dispose();
  });

  group('Offline Mode', () {
    test('Works without network connection', () async {
      // 1. Proverimo da smo offline
      expect(Services.connection.currentStatus.isConnected, false);

      // 2. Kreiramo test poruku
      final message = Message(
        id: 'offline_test_1',
        content: 'Offline message',
        senderId: 'test_sender',
        timestamp: DateTime.now(),
      );

      // 3. Sačuvamo lokalno
      final saveResult = await Services.storage.saveMessage(message);
      expect(saveResult.isSuccess, true);

      // 4. Proverimo da možemo da je učitamo
      final loadResult = await Services.storage.getMessages();
      expect(loadResult.isSuccess, true);
      expect(loadResult.data!.length, 1);
      expect(loadResult.data!.first.id, message.id);
    });

    test('Queues messages for later sync', () async {
      // 1. Kreiramo nekoliko poruka u offline modu
      final messages = List.generate(
        3,
        (i) => Message(
          id: 'offline_batch_$i',
          content: 'Offline message $i',
          senderId: 'test_sender',
          timestamp: DateTime.now(),
        ),
      );

      // 2. Dodamo ih u queue
      for (final msg in messages) {
        await Services.sync.queueMessage(msg);
      }

      // 3. Proverimo queue
      final queueResult = await Services.sync.getPendingMessages();
      expect(queueResult.data!.length, 3);

      // 4. Simuliramo povratak online
      // (ovo će automatski pokrenuti sync u pravoj implementaciji)
      await Services.sync.sync();

      // 5. Proverimo da su poruke poslate
      await Future.delayed(const Duration(seconds: 1));
      final finalQueue = await Services.sync.getPendingMessages();
      expect(finalQueue.data!.isEmpty, true);
    });

    test('Handles network transitions', () async {
      // 1. Počinjemo offline
      expect(Services.connection.currentStatus.isConnected, false);

      // 2. Dodamo poruku u offline modu
      final message = Message(
        id: 'transition_test_1',
        content: 'Transition test message',
        senderId: 'test_sender',
        timestamp: DateTime.now(),
      );
      await Services.sync.queueMessage(message);

      // 3. Proverimo queue
      var queueResult = await Services.sync.getPendingMessages();
      expect(queueResult.data!.length, 1);

      // 4. Simuliramo prelazak online
      await Services.connection.checkConnection();
      await Services.sync.sync();

      // 5. Proverimo da je poruka poslata
      await Future.delayed(const Duration(seconds: 1));
      queueResult = await Services.sync.getPendingMessages();
      expect(queueResult.data!.isEmpty, true);
    });
  });
}
