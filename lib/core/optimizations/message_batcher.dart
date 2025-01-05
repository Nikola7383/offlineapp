class MessageBatcher {
  static const int MAX_BATCH_SIZE = 100;
  static const Duration BATCH_WINDOW = Duration(milliseconds: 100);

  final Queue<Message> _messageQueue = Queue();
  Timer? _batchTimer;

  Future<void> addMessage(Message message) async {
    _messageQueue.add(message);

    if (_messageQueue.length >= MAX_BATCH_SIZE) {
      await _processBatch();
    } else if (_batchTimer == null) {
      _batchTimer = Timer(BATCH_WINDOW, _processBatch);
    }
  }

  Future<void> _processBatch() async {
    _batchTimer?.cancel();
    _batchTimer = null;

    if (_messageQueue.isEmpty) return;

    final batch = _messageQueue.toList();
    _messageQueue.clear();

    // Process batch
    await _saveBatch(batch);
  }
}
