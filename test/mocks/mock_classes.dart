import 'package:mockito/annotations.dart';
import 'package:secure_event_app/core/interfaces/logger_service_interface.dart';
import 'package:secure_event_app/core/interfaces/metrics_collector_interface.dart';
import 'package:secure_event_app/core/interfaces/communication_manager_interface.dart';
import 'package:secure_event_app/core/interfaces/test_data_generator_interface.dart';

@GenerateMocks([
  ILoggerService,
  IMetricsCollector,
  ICommunicationManager,
  ITestDataGenerator,
], customMocks: [])
void main() {}
