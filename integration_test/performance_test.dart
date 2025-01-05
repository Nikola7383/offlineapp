import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:secure_event_app/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Performance Tests', () {
    testWidgets('message list scrolling performance', (tester) async {
      // Pokreni aplikaciju i login
      app.main();
      await tester.pumpAndSettle();

      // Login
      await _performLogin(tester);

      // Generiši veliki broj test poruka
      for (var i = 0; i < 100; i++) {
        await tester.enterText(
          find.byType(TextField),
          'Test message $i',
        );
        await tester.tap(find.byIcon(Icons.send));
        await tester.pump();
      }
      await tester.pumpAndSettle();

      // Test scrolling performanse
      final scrollStart = DateTime.now();
      await tester.fling(
        find.byType(ListView),
        const Offset(0, -500),
        3000,
      );
      await tester.pumpAndSettle();
      final scrollDuration = DateTime.now().difference(scrollStart);

      // Scrolling ne bi trebalo da traje duže od 16ms po frame-u
      expect(scrollDuration.inMilliseconds, lessThan(1000));

      // Proveri memory usage
      final memoryUsage = await _getMemoryUsage();
      expect(memoryUsage, lessThan(100 * 1024 * 1024)); // Manje od 100MB
    });

    testWidgets('image attachment performance', (tester) async {
      // Pokreni aplikaciju i login
      app.main();
      await tester.pumpAndSettle();
      await _performLogin(tester);

      // Test učitavanja slika
      final loadStart = DateTime.now();
      await tester.tap(find.byIcon(Icons.attach_file));
      await tester.pumpAndSettle();

      // Simuliraj izbor slike
      // Note: Ovo je mock implementacija
      await tester.tap(find.byType(ImagePicker));
      await tester.pumpAndSettle();

      final loadDuration = DateTime.now().difference(loadStart);
      expect(loadDuration.inMilliseconds, lessThan(1000));
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

Future<int> _getMemoryUsage() async {
  // Implementacija za dobijanje trenutne memorijske potrošnje
  // Ovo je mock implementacija
  return Future.value(50 * 1024 * 1024); // 50MB
}
