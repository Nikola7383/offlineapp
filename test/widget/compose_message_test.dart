import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/core/services/service_locator.dart';
import 'package:secure_event_app/ui/widgets/compose_message.dart';

void main() {
  setUp(() async {
    await ServiceLocator.instance.initialize();
  });

  tearDown(() async {
    await ServiceLocator.instance.dispose();
  });

  group('ComposeMessage Widget', () {
    testWidgets('can compose and queue message in offline mode',
        (tester) async {
      // Build widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ComposeMessage(),
          ),
        ),
      );

      // Enter message text
      await tester.enterText(
        find.byType(TextField),
        'Test offline message',
      );
      await tester.pump();

      // Tap send button
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      // Verify message is queued
      final pendingMessages = await ServiceLocator.instance
          .get<ISyncService>()
          .getPendingMessages();

      expect(pendingMessages.data!.length, 1);
      expect(
        pendingMessages.data!.first.content,
        'Test offline message',
      );
    });

    testWidgets('shows sending indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ComposeMessage(),
          ),
        ),
      );

      // Enter message and send
      await tester.enterText(
        find.byType(TextField),
        'Test message',
      );
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      // Should show sending indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for send to complete
      await tester.pumpAndSettle();

      // Sending indicator should be gone
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });
  });
}
