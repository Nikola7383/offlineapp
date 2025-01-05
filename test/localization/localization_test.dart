import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/core/localization/l10n.dart';

void main() {
  group('Localization Tests', () {
    testWidgets('Should support all required languages', (tester) async {
      final l10n = await L10n.load();

      for (final locale in L10n.supportedLocales) {
        await l10n.setLocale(locale);

        // Provera kritičnih stringova
        expect(l10n.appTitle, isNotEmpty);
        expect(l10n.errorMessages, areTranslated);
        expect(l10n.navigationLabels, areComplete);
      }
    });

    testWidgets('Should handle RTL languages correctly', (tester) async {
      await tester.pumpWidget(
        const MyApp(locale: Locale('ar')), // Arapski
      );

      // Provera RTL layouta
      expect(find.byType(Directionality), findsOneWidget);
      final direction = tester
          .widget<Directionality>(
            find.byType(Directionality),
          )
          .textDirection;
      expect(direction, equals(TextDirection.rtl));

      // Provera UI elemenata
      expect(find.byType(TextField), isCorrectlyAligned);
      expect(find.byType(ListView), hasCorrectScrollDirection);
    });

    testWidgets('Should maintain formatting across languages', (tester) async {
      for (final locale in L10n.supportedLocales) {
        await tester.pumpWidget(
          MyApp(locale: locale),
        );

        // Provera formatiranja
        expect(find.byType(Text), maintainsFormatting);
        expect(find.byType(TextField), fitsContent);
        expect(find.byType(Button), hasConsistentLayout);
      }
    });
  });
}
