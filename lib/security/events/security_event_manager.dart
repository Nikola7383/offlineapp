import 'dart:async';

class SecurityEventManager {
  static final SecurityEventManager _instance =
      SecurityEventManager._internal();
  final Map<String, List<SecurityEventHandler>> _eventHandlers = {};
  final Queue<SecurityEvent> _eventQueue = Queue();
  bool _isProcessing = false;

  factory SecurityEventManager() {
    return _instance;
  }

  SecurityEventManager._internal() {
    _initializeEventProcessing();
  }

  void _initializeEventProcessing() {
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (!_isProcessing && _eventQueue.isNotEmpty) {
        _processNextEvent();
      }
    });
  }

  Future<void> _processNextEvent() async {
    if (_eventQueue.isEmpty) return;

    _isProcessing = true;
    try {
      final event = _eventQueue.removeFirst();
      final handlers = _eventHandlers[event.type] ?? [];

      for (var handler in handlers) {
        await handler.handleEvent(event);
      }
    } finally {
      _isProcessing = false;
    }
  }

  void registerHandler(String eventType, SecurityEventHandler handler) {
    _eventHandlers.putIfAbsent(eventType, () => []).add(handler);
  }

  void publishEvent(SecurityEvent event) {
    _eventQueue.add(event);
  }
}

class SecurityEvent {
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String? sourceId;
  final SecurityLevel severity;

  SecurityEvent(
      {required this.type,
      required this.data,
      required this.timestamp,
      this.sourceId,
      required this.severity});
}

abstract class SecurityEventHandler {
  Future<void> handleEvent(SecurityEvent event);
}
