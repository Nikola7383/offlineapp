import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:your_app/main.dart';

void main() {
  group('UI Performance Tests', () {
    testWidgets('Message list should scroll smoothly', (tester) async {
      await tester.pumpWidget(const MyApp());
      await _loadTestMessages(1000); // Učitaj 1000 test poruka

      final stopwatch = Stopwatch()..start();

      // Simulira brzi scroll
      await tester.fling(
        find.byType(ListView),
        const Offset(0, -3000),
        3000,
      );

      // Meri frame-ove tokom animacije
      await tester.pumpAndSettle();
      stopwatch.stop();

      // Provera da li je scroll gladak (60fps = 16.67ms po frame-u)
      final framesDropped = stopwatch.elapsedMilliseconds ~/ 16.67;
      expect(framesDropped, lessThan(5)); // Dozvoljava max 5 dropped frames
    });

    testWidgets('Message composition should be responsive', (tester) async {
      await tester.pumpWidget(const MyApp());

      final stopwatch = Stopwatch()..start();

      // Simulira brzo kucanje
      for (var i = 0; i < 100; i++) {
        await tester.enterText(
          find.byType(TextField),
          'Performance test message $i',
        );
        await tester.pump(const Duration(milliseconds: 16)); // 60fps
      }

      stopwatch.stop();

      // Provera da li UI ostaje responzivan
      expect(stopwatch.elapsedMilliseconds ~/ 100,
          lessThan(20)); // max 20ms po operaciji
    });
  });
}
