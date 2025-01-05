@injectable
class MessageQueue extends InjectableService implements Disposable {
  static const MAX_QUEUE_SIZE = 10000;
  static const PROCESS_BATCH_SIZE = 100;

  final Queue<Message> _queue = Queue();
  final _queueController = StreamController<List<Message>>.broadcast();
  Timer? _processTimer;
  bool _isProcessing = false;

  Stream<List<Message>> get messageBatches => _queueController.stream;

  @override
  Future<void> initialize() async {
    await super.initialize();
    _startProcessing();
  }

  void enqueue(Message message) {
    if (_queue.length >= MAX_QUEUE_SIZE) {
      logger.warning('Queue size limit reached, dropping oldest message');
      _queue.removeFirst();
    }
    _queue.add(message);
  }

  void _startProcessing() {
    _processTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => _processBatch(),
    );
  }

  Future<void> _processBatch() async {
    if (_isProcessing || _queue.isEmpty) return;

    _isProcessing = true;
    try {
      final batch = _queue.take(PROCESS_BATCH_SIZE).toList();

      _queue.removeWhere((msg) => batch.contains(msg));
      _queueController.add(batch);
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Future<void> dispose() async {
    _processTimer?.cancel();
    await _queueController.close();
    _queue.clear();
    await super.dispose();
  }
}
