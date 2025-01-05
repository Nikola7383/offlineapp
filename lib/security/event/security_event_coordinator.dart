import 'dart:async';

class SecurityEventCoordinator {
  final Map<String, List<SecurityEventHandler>> _eventHandlers = {};
  final Map<String, Priority> _eventPriorities = {};
  final StreamController<SecurityEvent> _eventStream =
      StreamController.broadcast();

  // Event queue za sekvencijalno procesiranje
  final _eventQueue = StreamController<SecurityEvent>();

  SecurityEventCoordinator() {
    _initializeEventProcessing();
  }

  void _initializeEventProcessing() {
    _eventQueue.stream.listen((event) async {
      try {
        await _processEvent(event);
      } catch (e) {
        await SecurityErrorHandler().handleError(SecurityError(
            type: ErrorType.eventProcessing,
            severity: ErrorSeverity.high,
            message: 'Failed to process event: $e'));
      }
    });
  }

  void registerHandler(String eventType, SecurityEventHandler handler,
      {Priority priority = Priority.normal}) {
    _eventHandlers.putIfAbsent(eventType, () => []).add(handler);
    _eventPriorities[eventType] = priority;

    // Sortiranje handlera po prioritetu
    _eventHandlers[eventType]
        ?.sort((a, b) => a.priority.index.compareTo(b.priority.index));
  }

  Future<void> handleEvent(SecurityEvent event) async {
    try {
      // Dodavanje događaja u queue
      _eventQueue.add(event);

      // Emitovanje događaja za monitoring
      _eventStream.add(event);
    } catch (e) {
      await SecurityErrorHandler().handleError(SecurityError(
          type: ErrorType.eventHandling,
          severity: ErrorSeverity.medium,
          message: 'Failed to handle event: $e'));
    }
  }

  Future<void> _processEvent(SecurityEvent event) async {
    final handlers = _eventHandlers[event.type] ?? [];

    if (handlers.isEmpty) {
      // Log warning ako nema registrovanih handlera
      SecurityLogger()
          .logWarning('No handlers registered for event type: ${event.type}');
      return;
    }

    // Sekvencijalno izvršavanje handlera
    for (var handler in handlers) {
      try {
        await handler.handle(event);
      } catch (e) {
        await SecurityErrorHandler().handleError(SecurityError(
            type: ErrorType.handlerExecution,
            severity: ErrorSeverity.high,
            message: 'Handler failed to process event: $e'));

        // Prekid izvršavanja ako je kritična greška
        if (handler.stopOnError) break;
      }
    }
  }

  Stream<SecurityEvent> get eventStream => _eventStream.stream;

  void dispose() {
    _eventStream.close();
    _eventQueue.close();
  }
}

abstract class SecurityEventHandler {
  final Priority priority;
  final bool stopOnError;

  SecurityEventHandler(
      {this.priority = Priority.normal, this.stopOnError = false});

  Future<void> handle(SecurityEvent event);
}

enum Priority { low, normal, high, critical }

class SecurityEvent {
  final String type;
  final dynamic data;
  final DateTime timestamp;
  final Priority priority;

  SecurityEvent(
      {required this.type,
      required this.data,
      required this.priority,
      DateTime? timestamp})
      : this.timestamp = timestamp ?? DateTime.now();
}
