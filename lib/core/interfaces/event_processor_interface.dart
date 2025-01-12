import 'dart:async';
import 'base_service.dart';
import '../models/event.dart';
import '../models/event_processing_result.dart';
import '../models/processor_status.dart';

/// Interfejs za procesiranje događaja
abstract class IEventProcessor implements IService {
  /// Stream procesiranih događaja
  Stream<Event> get processedEvents;

  /// Procesira događaj i vraća rezultat procesiranja
  Future<EventProcessingResult> processEvent(Event event);

  /// Validira događaj pre procesiranja
  Future<bool> validateEvent(Event event);

  /// Određuje prioritet događaja
  Future<int> prioritizeEvent(Event event);

  /// Agregira listu događaja
  Future<List<Event>> aggregateEvents(List<Event> events);

  /// Filtrira događaje prema zadatom filteru
  Future<List<Event>> filterEvents(List<Event> events, EventFilter filter);

  /// Proverava status procesora
  Future<ProcessorStatus> checkStatus();

  /// Sinhronizuje stanje sa drugim procesorima
  Future<void> synchronizeState();

  /// Pauzira procesiranje događaja
  Future<void> pause();

  /// Nastavlja procesiranje događaja
  Future<void> resume();

  /// Čisti red za čekanje
  Future<void> clearQueue();
}

/// Filter za događaje
class EventFilter {
  final EventType? type;
  final EventPriority? priority;
  final EventTimePeriod? timePeriod;
  final EventStatus? status;
  final bool? isEmergency;
  final bool? isSecurityRelated;

  const EventFilter({
    this.type,
    this.priority,
    this.timePeriod,
    this.status,
    this.isEmergency,
    this.isSecurityRelated,
  });
}

/// Vremenski period za događaje
class EventTimePeriod {
  final DateTime startTime;
  final DateTime endTime;

  const EventTimePeriod({
    required this.startTime,
    required this.endTime,
  });

  bool includes(DateTime time) {
    return time.isAfter(startTime) && time.isBefore(endTime);
  }
}
