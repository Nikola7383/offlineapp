import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:your_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Recovery Integration Tests', () {
    testWidgets('Should recover from database corruption', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Simuliraj crash
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'crash',
        null,
        (ByteData? data) async {},
      );

      // Act - Restart app
      app.main();
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Glasnik'), findsOneWidget);
      expect(find.text('Error'), findsNothing);
    });

    testWidgets('Should handle storage cleanup', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Simuliraj puno poruka
      for (var i = 0; i < 1000; i++) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byType(TextField),
          'Test message $i',
        );
        await tester.tap(find.text('Pošalji'));
        await tester.pumpAndSettle();
      }

      // Act - Trigger storage cleanup
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Očisti storage'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Storage očišćen'), findsOneWidget);
    });
  });
}
