import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:your_app/main.dart';

void main() {
  group('Accessibility Tests', () {
    testWidgets('Should support screen readers', (tester) async {
      await tester.pumpWidget(const MyApp());

      // Provera semantics oznaka
      final semantics = tester.getSemantics(find.byType(MaterialApp));

      expect(
        semantics.getSemanticsData().label,
        contains('Glasnik Messenger'),
      );

      // Provera navigacije
      final navButtons = find.byType(NavigationButton);
      for (final button in tester.widgetList(navButtons)) {
        expect(
          button.semanticsLabel,
          isNotNull,
        );
      }
    });

    testWidgets('Should support high contrast', (tester) async {
      await tester.pumpWidget(const MyApp());

      // Provera kontrasta boja
      final textWidgets = find.byType(Text);
      for (final text in tester.widgetList<Text>(textWidgets)) {
        final contrast = _calculateContrast(
          text.style?.color ?? Colors.black,
          Theme.of(tester.element(find.byType(MaterialApp))).backgroundColor,
        );
        expect(contrast, greaterThanOrEqualTo(4.5)); // WCAG AA standard
      }
    });

    testWidgets('Should support dynamic text scaling', (tester) async {
      await tester.pumpWidget(const MyApp());

      // Test sa različitim veličinama teksta
      final textScales = [1.0, 1.5, 2.0];

      for (final scale in textScales) {
        await tester.binding.setSurfaceSize(Size(
          400 * scale,
          800 * scale,
        ));

        await tester.pumpAndSettle();

        // Provera da li se UI pravilno prilagođava
        expect(find.byType(Overflow), findsNothing);
      }
    });
  });
}
