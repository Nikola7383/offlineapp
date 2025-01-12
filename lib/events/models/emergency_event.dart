import 'package:freezed_annotation/freezed_annotation.dart';

part 'emergency_event.freezed.dart';
part 'emergency_event.g.dart';

/// Model koji predstavlja hitni događaj
@freezed
class EmergencyEvent with _$EmergencyEvent {
  const factory EmergencyEvent({
    required String id,
    required EventType type,
    required Map<String, dynamic> data,
    required DateTime timestamp,
    @Default(EventPriority.normal) EventPriority priority,
  }) = _EmergencyEvent;

  factory EmergencyEvent.fromJson(Map<String, dynamic> json) =>
      _$EmergencyEventFromJson(json);
}

/// Tip hitnog događaja
enum EventType {
  /// Admin se pojavio
  adminAppeared,

  /// Seed se pojavio
  seedAppeared,

  /// Promena stanja
  stateChange,

  /// Promena mreže
  networkChange,

  /// Standardni događaj
  standard
}

/// Prioritet događaja
enum EventPriority {
  /// Kritičan prioritet
  critical,

  /// Visok prioritet
  high,

  /// Normalan prioritet
  normal,

  /// Nizak prioritet
  low
}

/// Rezultat procesiranja događaja
@freezed
class EventProcessingResult with _$EventProcessingResult {
  const factory EventProcessingResult({
    required bool success,
    required EmergencyEvent event,
    String? error,
    Map<String, dynamic>? metadata,
  }) = _EventProcessingResult;

  factory EventProcessingResult.fromJson(Map<String, dynamic> json) =>
      _$EventProcessingResultFromJson(json);

  /// Kreira rezultat za događaj koji je stavljen u red
  factory EventProcessingResult.queued(EmergencyEvent event) =>
      EventProcessingResult(
        success: true,
        event: event,
        metadata: {'queued': true},
      );
}
