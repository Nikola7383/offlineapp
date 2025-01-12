import 'package:injectable/injectable.dart';
import 'base_service.dart';
import '../models/test_message.dart';

abstract class ITestDataGenerator extends IService {
  Future<List<TestMessage>> generateLargeDataSet({
    required int messageCount,
    required List<int> sizesInKB,
  });

  Future<void> initialize();
  Future<void> dispose();
}
