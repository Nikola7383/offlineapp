import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/screens/process_management_screen.dart';

void main() {
  group('ProcessManagementScreen', () {
    late ProviderContainer container;
    late String nodeId;

    setUp(() {
      container = ProviderContainer();
      nodeId = 'test-node';
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('should render process management screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: ProcessManagementScreen(nodeId: nodeId),
          ),
        ),
      );

      expect(find.text('Upravljanje procesima'), findsOneWidget);
      expect(find.text('Pokreni novi proces'), findsOneWidget);
      expect(find.text('Network Monitor'), findsOneWidget);
      expect(find.text('Security Scanner'), findsOneWidget);
      expect(find.text('Nema aktivnih procesa'), findsOneWidget);
    });
  });
}
