import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/core/services/storage_service.dart';
import '../../test_infrastructure.dart';

void main() {
  late TestInfrastructure infra;
  late StorageService storageService;

  setUp(() async {
    infra = TestInfrastructure();
    await infra.setUp();
    storageService = StorageService(infra.database);
    await storageService.initialize();
  });

  tearDown(() async {
    await storageService.dispose();
    await infra.tearDown();
  });

  group('StorageService', () {
    test('should save and retrieve messages', () async {
      // Arrange
      final message = infra.createTestMessage();

      // Act - Save
      final saveResult = await storageService.saveMessage(message);
      expect(saveResult.isSuccess, true);

      // Act - Retrieve
      final getResult = await storageService.getMessages();
      expect(getResult.isSuccess, true);
      expect(getResult.data!.length, 1);
      expect(getResult.data!.first.id, message.id);
    });

    test('should handle database errors', () async {
      // Arrange
      final message = infra.createTestMessage();
      when(infra.database.set(any, any))
          .thenAnswer((_) async => Result.failure('Database error'));

      // Act
      final result = await storageService.saveMessage(message);

      // Assert
      expect(result.isSuccess, false);
      expect(result.error, contains('Database error'));
    });
  });
}
