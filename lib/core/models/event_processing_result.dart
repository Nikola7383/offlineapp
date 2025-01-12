import 'event.dart';

class EventProcessingResult {
  final bool success;
  final Event event;
  final String? error;
  final Map<String, dynamic>? metadata;

  EventProcessingResult({
    required this.success,
    required this.event,
    this.error,
    this.metadata,
  });
}
