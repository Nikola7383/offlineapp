import '../../core/models/event.dart';
import '../../core/models/security_status.dart';
import '../../core/models/event_processing_result.dart';
import 'base_service.dart';

abstract class ISecurityEventProcessor implements IService {
  Stream<Event> get processedEvents;
  Future<EventProcessingResult> processEvent(Event event);
  Future<SecurityManagerStatus> checkStatus();
  Future<void> synchronizeState();
  Future<void> pause();
  Future<void> resume();
  Future<void> clearQueue();
}
