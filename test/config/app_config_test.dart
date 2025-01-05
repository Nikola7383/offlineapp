import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/config/app_config.dart';

void main() {
  group('AppConfig Tests', () {
    test('mesh configuration values are valid', () {
      expect(AppConfig.meshTimeout, greaterThan(0));
      expect(AppConfig.maxRetries, greaterThan(0));
      expect(AppConfig.maxConnections, greaterThan(0));
      expect(AppConfig.messageRateLimit, greaterThan(0));
    });

    test('security configuration values are valid', () {
      expect(AppConfig.keyLength, equals(256));
      expect(AppConfig.maxFileSize, greaterThan(0));
      expect(AppConfig.allowedFileTypes, isNotEmpty);
    });

    test('rate limits are properly configured', () {
      expect(AppConfig.rateLimits, isNotEmpty);
      expect(AppConfig.rateLimits['message'], greaterThan(0));
      expect(AppConfig.rateLimits['file'], greaterThan(0));
    });
  });
}
