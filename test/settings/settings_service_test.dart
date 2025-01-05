import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:secure_event_app/core/settings/settings_service.dart';
import 'package:secure_event_app/core/logging/logger_service.dart';

class MockLogger extends Mock implements LoggerService {}

void main() {
  late SettingsService settingsService;
  late MockLogger mockLogger;

  setUp(() async {
    mockLogger = MockLogger();
    SharedPreferences.setMockInitialValues({});
    settingsService = SettingsService(logger: mockLogger);
    await settingsService.initialize();
  });

  group('SettingsService Tests', () {
    test('should set and get string setting', () async {
      // Act
      await settingsService.setSetting('test_key', 'test_value');
      final value = settingsService.getSetting<String>('test_key');

      // Assert
      expect(value, equals('test_value'));
    });

    test('should set and get bool setting', () async {
      // Act
      await settingsService.setSetting('notifications_enabled', true);
      final value = settingsService.getSetting<bool>('notifications_enabled');

      // Assert
      expect(value, isTrue);
    });

    test('should remove setting', () async {
      // Arrange
      await settingsService.setSetting('test_key', 'test_value');

      // Act
      await settingsService.removeSetting('test_key');
      final value = settingsService.getSetting<String>('test_key');

      // Assert
      expect(value, isNull);
    });

    test('should set default settings', () async {
      // Act
      await settingsService.setDefaultSettings();

      // Assert
      expect(settingsService.getSetting<bool>('notifications_enabled'), isTrue);
      expect(settingsService.getSetting<bool>('dark_mode'), isFalse);
      expect(settingsService.getSetting<int>('message_retention_days'),
          equals(30));
    });
  });
}
