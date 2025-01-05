import 'package:flutter_test/flutter_test.dart';
import 'package:secure_event_app/core/logging/logger_service.dart';

class TestHelper {
  static LoggerService getTestLogger() {
    return LoggerService();
  }

  static Future<void> simulateCompleteSystemFailure() async {
    // Test implementacija
    await Future.delayed(const Duration(milliseconds: 100));
  }

  static Future<void> simulateCriticalFailure() async {
    // Test implementacija
    await Future.delayed(const Duration(milliseconds: 100));
  }

  static Future<Map<String, dynamic>> prepareTestData() async {
    return {
      'testKey': 'testValue',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
} 