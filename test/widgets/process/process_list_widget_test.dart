import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/mesh/models/process_info.dart';
import 'package:secure_event_app/mesh/process/process_manager.dart';
import 'package:secure_event_app/mesh/providers/process_manager_provider.dart';
import 'package:secure_event_app/widgets/process/process_list_widget.dart';

class MockProcessManager extends ProcessManager {
  List<ProcessInfo> processes;
  final bool shouldThrow;
  final _stateController = StreamController<ProcessStateChange>.broadcast();

  MockProcessManager({
    this.processes = const [],
    this.shouldThrow = false,
  });

  @override
  Future<List<ProcessInfo>> getActiveProcesses(String nodeId) async {
    if (shouldThrow) {
      throw Exception('Test error');
    }
    return processes;
  }

  @override
  Stream<ProcessStateChange> get processStateChanges => _stateController.stream;

  void addProcess(ProcessInfo process) {
    processes = [...processes, process];
    _stateController.add(
      ProcessStateChange(
        nodeId: process.nodeId,
        processId: process.id,
        status: process.status,
      ),
    );
  }

  @override
  void dispose() {
    _stateController.close();
    super.dispose();
  }
}

final mockActiveProcessesProvider =
    StreamProvider.family<List<ProcessInfo>, String>(
  (ref, nodeId) async* {
    final manager = ref.watch(processManagerProvider);
    final processes = await manager.getActiveProcesses(nodeId);
    yield processes;

    await for (final _ in manager.processStateChanges) {
      final updatedProcesses = await manager.getActiveProcesses(nodeId);
      yield updatedProcesses;
    }
  },
);

void main() {
  group('ProcessListWidget', () {
    late ProviderContainer container;
    late String nodeId;
    late List<ProcessInfo> testProcesses;
    late MockProcessManager mockManager;

    setUp(() {
      nodeId = 'test-node';
      testProcesses = [
        ProcessInfo(
          id: 'test_process_1',
          nodeId: nodeId,
          name: 'Test Process 1',
          status: ProcessStatus.running,
          priority: ProcessPriority.normal,
          startTime: DateTime.now(),
          cpuUsage: 50.0,
          memoryUsageMb: 1024,
        ),
        ProcessInfo(
          id: 'test_process_2',
          nodeId: nodeId,
          name: 'Test Process 2',
          status: ProcessStatus.paused,
          priority: ProcessPriority.high,
          startTime: DateTime.now(),
          cpuUsage: 25.0,
          memoryUsageMb: 512,
        ),
      ];
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('should show loading indicator initially',
        (WidgetTester tester) async {
      mockManager = MockProcessManager(processes: testProcesses);
      container = ProviderContainer(
        overrides: [
          processManagerProvider.overrideWithValue(mockManager),
          activeProcessesProvider
              .overrideWithProvider(mockActiveProcessesProvider),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: ProcessListWidget(nodeId: nodeId),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error message when loading fails',
        (WidgetTester tester) async {
      mockManager = MockProcessManager(shouldThrow: true);
      container = ProviderContainer(
        overrides: [
          processManagerProvider.overrideWithValue(mockManager),
          activeProcessesProvider
              .overrideWithProvider(mockActiveProcessesProvider),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: ProcessListWidget(nodeId: nodeId),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        find.text('Greška prilikom učitavanja procesa: Exception: Test error'),
        findsOneWidget,
      );
    });

    testWidgets('should show message when no processes are active',
        (WidgetTester tester) async {
      mockManager = MockProcessManager();
      container = ProviderContainer(
        overrides: [
          processManagerProvider.overrideWithValue(mockManager),
          activeProcessesProvider
              .overrideWithProvider(mockActiveProcessesProvider),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: ProcessListWidget(nodeId: nodeId),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Nema aktivnih procesa'), findsOneWidget);
    });

    testWidgets('should show list of active processes',
        (WidgetTester tester) async {
      mockManager = MockProcessManager(processes: testProcesses);
      container = ProviderContainer(
        overrides: [
          processManagerProvider.overrideWithValue(mockManager),
          activeProcessesProvider
              .overrideWithProvider(mockActiveProcessesProvider),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: ProcessListWidget(nodeId: nodeId),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      for (final process in testProcesses) {
        expect(find.text(process.name), findsOneWidget);
        expect(find.text('Status: ${process.status}'), findsOneWidget);
        expect(find.text('Prioritet: ${process.priority}'), findsOneWidget);
        expect(find.text('CPU: ${process.cpuUsage.toStringAsFixed(1)}%'),
            findsOneWidget);
        expect(
            find.text('Memorija: ${process.memoryUsageMb} MB'), findsOneWidget);
      }
    });

    testWidgets('should show correct action buttons for running process',
        (WidgetTester tester) async {
      mockManager = MockProcessManager(processes: [testProcesses[0]]);
      container = ProviderContainer(
        overrides: [
          processManagerProvider.overrideWithValue(mockManager),
          activeProcessesProvider
              .overrideWithProvider(mockActiveProcessesProvider),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: ProcessListWidget(nodeId: nodeId),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byIcon(Icons.pause), findsOneWidget);
      expect(find.byIcon(Icons.stop), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsNothing);
    });

    testWidgets('should show correct action buttons for paused process',
        (WidgetTester tester) async {
      mockManager = MockProcessManager(processes: [testProcesses[1]]);
      container = ProviderContainer(
        overrides: [
          processManagerProvider.overrideWithValue(mockManager),
          activeProcessesProvider
              .overrideWithProvider(mockActiveProcessesProvider),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: ProcessListWidget(nodeId: nodeId),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.stop), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsNothing);
    });

    testWidgets('should update list when new process is added',
        (WidgetTester tester) async {
      mockManager = MockProcessManager();
      container = ProviderContainer(
        overrides: [
          processManagerProvider.overrideWithValue(mockManager),
          activeProcessesProvider
              .overrideWithProvider(mockActiveProcessesProvider),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: ProcessListWidget(nodeId: nodeId),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Nema aktivnih procesa'), findsOneWidget);

      final newProcess = ProcessInfo(
        id: 'new_process',
        nodeId: nodeId,
        name: 'New Process',
        status: ProcessStatus.running,
        priority: ProcessPriority.normal,
        startTime: DateTime.now(),
      );

      mockManager.addProcess(newProcess);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('New Process'), findsOneWidget);
      expect(find.text('Status: ${ProcessStatus.running}'), findsOneWidget);
      expect(find.text('Prioritet: ${ProcessPriority.normal}'), findsOneWidget);
      expect(find.text('CPU: 0.0%'), findsOneWidget);
      expect(find.text('Memorija: 0 MB'), findsOneWidget);
    });
  });
}
