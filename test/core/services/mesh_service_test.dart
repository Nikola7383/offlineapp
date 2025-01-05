import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/models/message.dart';
import 'package:secure_event_app/core/services/mesh_service.dart';
import '../../helpers/test_helpers.mocks.dart';

void main() {
  late MockILoggerService mockLogger;
  late MeshService meshService;

  setUp(() {
    mockLogger = MockILoggerService();
    meshService = MeshService(mockLogger);
  });

  test('should send message when online', () async {
    // Arrange
    final message = Message(
      id: 'test1',
      content: 'test content',
      timestamp: DateTime.now(),
    );

    // Act
    final result = await meshService.sendMessage(message);

    // Assert
    expect(result.isSuccess, true);
  });

  test('should handle send failure', () async {
    // Arrange
    final message = Message(
      id: 'test2',
      content: 'test content',
      timestamp: DateTime.now(),
    );

    // Simulate network error
    meshService.simulateNetworkError = true;

    // Act
    final result = await meshService.sendMessage(message);

    // Assert
    expect(result.isSuccess, false);
    expect(result.error, contains('Network error'));
  });
}
