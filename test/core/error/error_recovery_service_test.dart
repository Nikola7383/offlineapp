import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/error/error_recovery_service.dart';
import 'package:secure_event_app/core/config/app_config.dart';
import '../mocks/mock_classes.dart';

void main() {
  late ErrorRecoveryService service;
  late MockLogger mockLogger;
  late MockStorage mockStorage;
  late MockMeshNetwork mockMesh;

  setUp(() {
    mockLogger = MockLogger();
    mockStorage = MockStorage();
    mockMesh = MockMeshNetwork();

    // Setup default behavior
    when(mockLogger.info(any)).thenAnswer((_) async {});
    when(mockLogger.warning(any)).thenAnswer((_) async {});
    when(mockLogger.error(any, any)).thenAnswer((_) async {});

    service = ErrorRecoveryService(
      logger: mockLogger,
      storage: mockStorage,
      meshNetwork: mockMesh,
    );
  });

  tearDown(() {
    service.dispose();
  });

  group('ErrorRecoveryService Tests', () {
    test('retries failed operations with backoff', () async {
      int attempts = 0;
      await service.registerFailedOperation(
        type: 'test_operation',
        data: 'test_data',
        operation: () async {
          attempts++;
          if (attempts < 2) throw 'Error';
          return;
        },
      );

      await Future.delayed(const Duration(seconds: 3));
      expect(attempts, 2);
      verify(mockLogger.info(any)).called(1);
    });

    test('respects max retries limit', () async {
      int attempts = 0;
      await service.registerFailedOperation(
        type: 'test_operation',
        data: 'test_data',
        operation: () async {
          attempts++;
          throw 'Error';
        },
      );

      await Future.delayed(const Duration(seconds: 5));
      expect(attempts, lessThanOrEqualTo(AppConfig.maxRetries));
      verify(mockLogger.error(any, any)).called(greaterThanOrEqualTo(1));
    });
  });
}
