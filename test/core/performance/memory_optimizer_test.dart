import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/performance/memory_optimizer.dart';
import 'package:secure_event_app/core/logging/logger_service.dart';

class MockLoggerService extends Mock implements LoggerService {}

void main() {
  late MemoryOptimizer optimizer;
  late MockLoggerService mockLogger;

  setUp(() {
    mockLogger = MockLoggerService();
    optimizer = MemoryOptimizer(logger: mockLogger);
  });

  tearDown(() {
    optimizer.dispose();
  });

  group('MemoryOptimizer Tests', () {
    test('caches and retrieves objects correctly', () {
      final testObject = {'test': 'data'};
      optimizer.cacheObject('test_key', testObject);

      final retrieved =
          optimizer.getCachedObject<Map<String, String>>('test_key');
      expect(retrieved, equals(testObject));
    });

    test('returns null for non-existent cache key', () {
      final retrieved = optimizer.getCachedObject<String>('non_existent');
      expect(retrieved, isNull);
    });

    test('handles weak references correctly', () async {
      optimizer.cacheObject('test_key', {'temporary': 'data'});

      // Simuliraj GC pressure
      List<int> memory = [];
      try {
        while (true) {
          memory.add(1);
        }
      } catch (e) {
        // Out of memory error expected
      }

      // Nakon GC pressure, weak reference bi trebalo da bude očišćena
      expect(optimizer.getCachedObject('test_key'), isNull);
    });
  });
}
