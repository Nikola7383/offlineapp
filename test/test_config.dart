import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class TestConfig {
  // Test timeouts
  static const timeout = Duration(seconds: 30);
  static const setupTimeout = Duration(seconds: 5);
  static const teardownTimeout = Duration(seconds: 5);

  // Batch processing configs
  static const messageProcessingDelay = Duration(seconds: 2);
  static const batchSize = 5;
  static const maxRetries = 3;

  // Mock behavior configs
  static const mockNetworkDelay = Duration(milliseconds: 100);
  static const mockDatabaseDelay = Duration(milliseconds: 50);
  static const mockLoggerDelay = Duration(milliseconds: 10);

  // Test data
  static const testSenderId = 'test_sender_1';
  static const testMessagePrefix = 'test_message_';

  // Mock response configs
  static const shouldSimulateNetworkErrors = false;
  static const shouldSimulateDbErrors = false;
  static const errorProbability = 0.1; // 10% chance of error
}

Future<void> configureTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Disable animations
  timeDilation = 1.0;

  // Add test-specific configurations
  await Future<void>.delayed(const Duration(milliseconds: 100));
}

// Helper za generisanje test poruka
Message createTestMessage(int index) {
  return Message(
    id: '${TestConfig.testMessagePrefix}$index',
    content: 'Test message $index',
    senderId: TestConfig.testSenderId,
    timestamp: DateTime.now(),
  );
}

// Helper za simulaciju network delay-a
Future<void> simulateNetworkDelay() async {
  await Future.delayed(TestConfig.mockNetworkDelay);
}

// Helper za simulaciju database delay-a
Future<void> simulateDatabaseDelay() async {
  await Future.delayed(TestConfig.mockDatabaseDelay);
}
