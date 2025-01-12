import '../../core/models/event.dart';
import '../../core/models/emergency_status.dart';
import '../../core/models/event_processing_result.dart';
import 'base_service.dart';

abstract class IEmergencyEventProcessor implements IService {
  Stream<Event> get processedEvents;
  Future<EventProcessingResult> processEvent(Event event);
  Future<EmergencyManagerStatus> checkStatus();
  Future<void> synchronizeState();
  Future<void> pause();
  Future<void> resume();
  Future<void> clearQueue();
}
