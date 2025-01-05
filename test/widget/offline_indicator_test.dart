import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/core/models/connection_models.dart';
import 'package:secure_event_app/core/services/service_locator.dart';
import 'package:secure_event_app/ui/widgets/offline_indicator.dart';
import 'package:secure_event_app/ui/widgets/sync_status_badge.dart';

void main() {
  setUp(() async {
    await ServiceLocator.instance.initialize();
  });

  tearDown(() async {
    await ServiceLocator.instance.dispose();
  });

  group('OfflineIndicator Widget', () {
    testWidgets('shows offline state correctly', (tester) async {
      // Build widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineIndicator(),
          ),
        ),
      );

      // Initially should show offline
      expect(find.text('Offline Mode'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);

      // Simulate going online
      await ServiceLocator.instance.get<IConnectionService>().checkConnection();
      await tester.pump();

      // Should update UI
      expect(find.text('Online'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_done), findsOneWidget);
    });

    testWidgets('shows pending messages count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncStatusBadge(),
          ),
        ),
      );

      // Initially no pending messages
      expect(find.text('0'), findsOneWidget);

      // Add a pending message
      final message = Message(
        id: 'test_ui_1',
        content: 'Test UI message',
        senderId: 'test_sender',
        timestamp: DateTime.now(),
      );
      await ServiceLocator.instance.get<ISyncService>().queueMessage(message);
      await tester.pump();

      // Should show 1 pending message
      expect(find.text('1'), findsOneWidget);
    });
  });
}
