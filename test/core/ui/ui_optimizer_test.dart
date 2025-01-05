import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/ui/ui_optimizer.dart';
import '../mocks/mock_classes.dart';

void main() {
  late UiOptimizer optimizer;
  late MockLogger mockLogger;

  setUp(() {
    mockLogger = MockLogger();
    when(mockLogger.warning(any)).thenAnswer((_) async {});
    optimizer = UiOptimizer(logger: mockLogger);
  });

  group('UiOptimizer Tests', () {
    test('tracks rebuilds correctly', () {
      const widgetId = 'test_widget';

      // Simulate multiple rebuilds
      for (var i = 0; i < 5; i++) {
        optimizer.trackRebuild(widgetId);
      }

      // Simulate rapid rebuilds
      for (var i = 0; i < 3; i++) {
        optimizer.trackRebuild(widgetId);
      }

      verify(mockLogger.warning(any)).called(greaterThanOrEqualTo(1));
    });

    test('reset clears tracking data', () {
      const widgetId = 'test_widget';
      optimizer.trackRebuild(widgetId);
      optimizer.resetTracking();

      // After reset, should not trigger warning
      optimizer.trackRebuild(widgetId);
      verifyNever(mockLogger.warning(any));
    });
  });
}
