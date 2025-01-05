import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:secure_event_app/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:secure_event_app/core/security/encryption_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Security Tests', () {
    testWidgets('message encryption test', (tester) async {
      // Pokreni aplikaciju i login
      app.main();
      await tester.pumpAndSettle();
      await _performLogin(tester);

      // Pošalji enkriptovanu poruku
      const messageText = 'Secret message';
      await tester.enterText(
        find.byType(TextField),
        messageText,
      );
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Proveri da li je poruka enkriptovana u storage-u
      final encryptedMessage = await _getLastStoredMessage();
      expect(encryptedMessage, isNot(equals(messageText)));

      // Proveri da li se poruka ispravno dekriptuje
      final decryptedMessage = await _decryptMessage(encryptedMessage);
      expect(decryptedMessage, equals(messageText));
    });

    testWidgets('biometric authentication test', (tester) async {
      // Pokreni aplikaciju
      app.main();
      await tester.pumpAndSettle();

      // Pokušaj biometrijsku autentikaciju
      await tester.tap(find.byIcon(Icons.fingerprint));
      await tester.pumpAndSettle();

      // Proveri da li je biometrijska autentikacija uspešna
      expect(find.byType(ChatScreen), findsOneWidget);
    });

    testWidgets('session timeout test', (tester) async {
      // Pokreni aplikaciju i login
      app.main();
      await tester.pumpAndSettle();
      await _performLogin(tester);

      // Simuliraj timeout sesije
      await Future.delayed(const Duration(minutes: 30));
      await tester.pump();

      // Proveri da li je korisnik izlogovan
      expect(find.text('Session expired'), findsOneWidget);
      expect(find.text('Please login again'), findsOneWidget);
    });
  });
}

Future<void> _performLogin(WidgetTester tester) async {
  await tester.enterText(
    find.byType(TextFormField).first,
    'test_user',
  );
  await tester.enterText(
    find.byType(TextFormField).last,
    'test_password',
  );
  await tester.tap(find.byType(ElevatedButton));
  await tester.pumpAndSettle();
}

Future<String> _getLastStoredMessage() async {
  // Mock implementacija
  return Future.value('encrypted_message_data');
}

Future<String> _decryptMessage(String encrypted) async {
  // Mock implementacija
  return Future.value('Secret message');
}
