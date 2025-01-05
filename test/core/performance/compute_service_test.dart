import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/performance/compute_service.dart';
import '../mocks/mock_classes.dart';

void main() {
  late ComputeService computeService;
  late MockLogger mockLogger;

  setUp(() {
    mockLogger = MockLogger();
    when(mockLogger.info(any)).thenAnswer((_) async {});
    when(mockLogger.error(any, any)).thenAnswer((_) async {});

    computeService = ComputeService(logger: mockLogger);
  });

  group('ComputeService Tests', () {
    test('executes task successfully', () async {
      final result = await computeService.executeTask<int, int>(
        taskId: 'test_task',
        params: 5,
        computation: (p) => Future.value(p * 2),
      );

      expect(result, equals(10));
      verify(mockLogger.info(any)).called(1);
    });

    test('handles task failure', () async {
      expect(
        () => computeService.executeTask<int, int>(
          taskId: 'failing_task',
          params: 5,
          computation: (p) => throw Exception('Test error'),
        ),
        throwsException,
      );

      verify(mockLogger.error(any, any)).called(1);
    });
  });
}
