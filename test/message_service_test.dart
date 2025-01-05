import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/core/services/message_service.dart';

void main() {
  late MessageService service;

  setUp(() {
    service = MessageService();
  });

  group('MessageService', () {
    test('should add and get messages', () {
      service.addMessage("Poruka 1");
      service.addMessage("Poruka 2");

      expect(service.messageCount, 2);
      expect(service.getMessages().first, "Poruka 1");
    });

    test('should delete message', () {
      service.addMessage("Poruka 1");
      service.addMessage("Poruka 2");

      service.deleteMessage(0);
      expect(service.messageCount, 1);
      expect(service.getMessages().first, "Poruka 2");
    });

    test('should clear messages', () {
      service.addMessage("Poruka 1");
      service.addMessage("Poruka 2");

      service.clearMessages();
      expect(service.messageCount, 0);
    });
  });
}
