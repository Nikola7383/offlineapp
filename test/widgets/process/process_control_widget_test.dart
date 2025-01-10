import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/widgets/process/process_control_widget.dart';
import 'package:secure_event_app/mesh/providers/process_manager_provider.dart';
import 'package:secure_event_app/mesh/process/process_manager.dart';

class MockProcessStarter extends ProcessStarter {
  final bool shouldThrow;

  MockProcessStarter({required super.manager, this.shouldThrow = false});

  @override
  Future<void> startNetworkMonitor(String nodeId) async {
    if (shouldThrow) {
      throw Exception('Test error');
    }
    await super.startNetworkMonitor(nodeId);
  }

  @override
  Future<void> startSecurityScanner(String nodeId) async {
    if (shouldThrow) {
      throw Exception('Test error');
    }
    await super.startSecurityScanner(nodeId);
  }
}

void main() {
  group('ProcessControlWidget', () {
    late ProviderContainer container;
    late String nodeId;

    setUp(() {
      container = ProviderContainer();
      nodeId = 'test-node';
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('should render process control buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: ProcessControlWidget(nodeId: nodeId),
            ),
          ),
        ),
      );

      expect(find.text('Network Monitor'), findsOneWidget);
      expect(find.text('Security Scanner'), findsOneWidget);
    });

    testWidgets('should show success message when starting network monitor',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: ProcessControlWidget(nodeId: nodeId),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Network Monitor'));
      await tester.pumpAndSettle();

      expect(find.text('Network Monitor je uspešno pokrenut'), findsOneWidget);
    });

    testWidgets('should show success message when starting security scanner',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: ProcessControlWidget(nodeId: nodeId),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Security Scanner'));
      await tester.pumpAndSettle();

      expect(find.text('Security Scanner je uspešno pokrenut'), findsOneWidget);
    });

    testWidgets('should show error message when starting process fails',
        (WidgetTester tester) async {
      // Override provider to throw error
      container = ProviderContainer(
        overrides: [
          processStarterProvider.overrideWithValue(
            MockProcessStarter(
              manager: ProcessManager(),
              shouldThrow: true,
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: ProcessControlWidget(nodeId: nodeId),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Network Monitor'));
      await tester.pump(); // Pump frame for error
      await tester.pump(const Duration(
          milliseconds: 50)); // Pump frame for snackbar animation
      await tester.pump(
          const Duration(milliseconds: 750)); // Pump frame for snackbar show

      expect(
        find.byType(SnackBar),
        findsOneWidget,
      );
      expect(
        find.text(
            'Greška prilikom pokretanja Network Monitor-a: Exception: Test error'),
        findsOneWidget,
      );
    });
  });
}
