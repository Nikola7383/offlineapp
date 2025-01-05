class SecureEventBus extends SecurityBaseComponent {
  final Map<EventType, List<_SecureSubscription>> _subscriptions = {};
  final MemoryEncryption _memoryEncryption;
  final MemoryGuard _memoryGuard;

  SecureEventBus()
      : _memoryEncryption = MemoryEncryption(),
        _memoryGuard = MemoryGuard() {
    _initializeEventBus();
  }

  void _initializeEventBus() {
    _memoryGuard.protectMemoryRegion(this);
  }

  Future<void> publish(
      AnonymousIdentity publisher, Uint8List encryptedEvent) async {
    await safeOperation(() async {
      final eventType = await _extractEventType(encryptedEvent);

      if (!_subscriptions.containsKey(eventType)) {
        return;
      }

      final subscribers = _subscriptions[eventType]!;

      for (final subscription in subscribers) {
        if (subscription.isValid) {
          await subscription.deliver(encryptedEvent);
        }
      }
    });
  }

  Stream<Uint8List> subscribe(
      AnonymousIdentity subscriber, EventType type) async* {
    final subscription = _SecureSubscription(subscriber);

    _subscriptions.putIfAbsent(type, () => []).add(subscription);

    await for (final event in subscription.stream) {
      yield event;
    }

    // Auto-cleanup nakon završetka stream-a
    _subscriptions[type]?.remove(subscription);
  }

  Future<void> reset() async {
    await safeOperation(() async {
      for (final subscriptions in _subscriptions.values) {
        for (final subscription in subscriptions) {
          await subscription.terminate();
        }
      }
      _subscriptions.clear();
    });
  }

  Future<EventType> _extractEventType(Uint8List encryptedEvent) async {
    // Bezbedno ekstraktovanje tipa eventa bez dekripcije celokupnog sadržaja
    return EventType.standard; // Placeholder
  }
}

class _SecureSubscription {
  final AnonymousIdentity _subscriber;
  final StreamController<Uint8List> _controller;
  final DateTime _created;

  _SecureSubscription(this._subscriber)
      : _controller = StreamController<Uint8List>(),
        _created = DateTime.now();

  bool get isValid => DateTime.now().difference(_created).inHours < 24;

  Stream<Uint8List> get stream => _controller.stream;

  Future<void> deliver(Uint8List event) async {
    if (!isValid) return;
    _controller.add(event);
  }

  Future<void> terminate() async {
    await _controller.close();
  }
}
