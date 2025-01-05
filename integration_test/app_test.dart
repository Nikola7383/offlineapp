import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:secure_event_app/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Test', () {
    testWidgets('full app flow test', (tester) async {
      // Pokreni aplikaciju
      app.main();
      await tester.pumpAndSettle();

      // Test 1: Proveri da li se prikazuje Login ekran
      expect(find.text('Secure Event App'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);

      // Test 2: Pokušaj login sa pogrešnim kredencijalima
      await tester.enterText(
        find.byType(TextFormField).first,
        'wrong_user',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'wrong_password',
      );
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Proveri da li se prikazuje error poruka
      expect(find.text('Invalid credentials'), findsOneWidget);

      // Test 3: Login sa ispravnim kredencijalima
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

      // Proveri da li je korisnik ulogovan i na chat ekranu
      expect(find.byType(ChatScreen), findsOneWidget);

      // Test 4: Slanje poruke
      final messageText = 'Test message ${DateTime.now()}';
      await tester.enterText(
        find.byType(TextField),
        messageText,
      );
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Proveri da li je poruka prikazana
      expect(find.text(messageText), findsOneWidget);

      // Test 5: Proveri funkcionalnost menija
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);

      // Test 6: Proveri settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);

      // Test 7: Logout
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      // Proveri da li se vratio na login ekran
      expect(find.text('Secure Event App'), findsOneWidget);
    });

    testWidgets('offline mode test', (tester) async {
      // Pokreni aplikaciju u offline modu
      app.main();
      await tester.pumpAndSettle();

      // Login
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

      // Proveri offline indikator
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);

      // Pokušaj slanja poruke
      final messageText = 'Offline message';
      await tester.enterText(
        find.byType(TextField),
        messageText,
      );
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Proveri da li je poruka sačuvana lokalno
      expect(find.text(messageText), findsOneWidget);
      expect(
          find.byIcon(Icons.access_time), findsOneWidget); // Pending indicator
    });
  });
}
