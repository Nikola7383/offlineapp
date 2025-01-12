import 'package:injectable/injectable.dart';

import '../core/interfaces/emergency_event_processor.dart';
import '../core/interfaces/security_event_processor.dart';
import '../core/interfaces/logger_service_interface.dart';
import 'processing/emergency_event_processor.dart';
import 'processing/security_event_processor.dart';

@module
abstract class EventsModule {
  @singleton
  IEmergencyEventProcessor emergencyEventProcessor(
    ILoggerService loggerService,
  ) =>
      EmergencyEventProcessor(loggerService);

  @singleton
  ISecurityEventProcessor securityEventProcessor(
    ILoggerService loggerService,
  ) =>
      SecurityEventProcessor(loggerService);
}
