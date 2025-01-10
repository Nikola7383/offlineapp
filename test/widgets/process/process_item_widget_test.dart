import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/mesh/models/process_info.dart';
import 'package:secure_event_app/widgets/process/process_item_widget.dart';

void main() {
  group('ProcessItemWidget', () {
    late ProviderContainer container;
    late ProcessInfo process;

    setUp(() {
      container = ProviderContainer();
      process = ProcessInfo(
        id: 'test_process_1',
        nodeId: 'test-node',
        name: 'test_process',
        status: ProcessStatus.running,
        priority: ProcessPriority.normal,
        startTime: DateTime.now(),
        cpuUsage: 50.0,
        memoryUsageMb: 1024,
        threadCount: 4,
        openFileCount: 10,
        networkConnectionCount: 2,
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('should render process item', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: ProcessItemWidget(
                nodeId: process.nodeId,
                process: process,
              ),
            ),
          ),
        ),
      );

      expect(find.text(process.name), findsOneWidget);
      expect(find.text('ID: ${process.id}'), findsOneWidget);
      expect(find.text('RUNNING'), findsOneWidget);
      expect(find.text('CPU: ${process.cpuUsage.toStringAsFixed(1)}%'),
          findsOneWidget);
      expect(
          find.text('Memorija: ${process.memoryUsageMb} MB'), findsOneWidget);
      expect(find.text('Threadovi: ${process.threadCount}'), findsOneWidget);
      expect(find.text('Otvoreni fajlovi: ${process.openFileCount}'),
          findsOneWidget);
      expect(find.text('Mrežne konekcije: ${process.networkConnectionCount}'),
          findsOneWidget);
    });

    testWidgets('should show pause button for running process',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: ProcessItemWidget(
                nodeId: process.nodeId,
                process: process,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.pause), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsNothing);
    });

    testWidgets('should show play button for paused process',
        (WidgetTester tester) async {
      process = process.copyWith(status: ProcessStatus.paused);

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: ProcessItemWidget(
                nodeId: process.nodeId,
                process: process,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsNothing);
    });

    testWidgets('should show stop button for all processes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: ProcessItemWidget(
                nodeId: process.nodeId,
                process: process,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.stop), findsOneWidget);
    });

    testWidgets('should show error message when action fails',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: ProcessItemWidget(
                nodeId: process.nodeId,
                process: process,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.stop));
      await tester.pumpAndSettle();

      expect(
        find.text(
            'Greška prilikom zaustavljanja procesa: Exception: Proces nije pronađen'),
        findsOneWidget,
      );
    });
  });
}
