class OptimizedMessageQueue {
  final DatabaseService _db;
  final CompressionService _compression;
  final LoggerService _logger;

  // Priority queues za različite tipove poruka
  final PriorityQueue<QueuedMessage> _highPriority = PriorityQueue();
  final PriorityQueue<QueuedMessage> _normalPriority = PriorityQueue();
  final PriorityQueue<QueuedMessage> _lowPriority = PriorityQueue();

  // Batch processing settings
  static const int BATCH_SIZE = 100;
  static const Duration BATCH_INTERVAL = Duration(milliseconds: 100);

  // Queue metrics
  final _metrics = QueueMetrics();

  OptimizedMessageQueue({
    required DatabaseService db,
    required CompressionService compression,
    required LoggerService logger,
  })  : _db = db,
        _compression = compression,
        _logger = logger {
    _initializeQueue();
  }

  Future<void> _initializeQueue() async {
    // Start batch processor
    Timer.periodic(BATCH_INTERVAL, (_) => _processBatch());

    // Restore unprocessed messages from DB
    await _restoreQueue();
  }

  Future<void> enqueue(Message message) async {
    try {
      final queuedMessage = await _prepareMessage(message);
      _routeToQueue(queuedMessage);
      _metrics.messageEnqueued();
    } catch (e) {
      _logger.error('Failed to enqueue message: $e');
      throw QueueException('Enqueue failed');
    }
  }

  Future<QueuedMessage> _prepareMessage(Message message) async {
    // 1. Compress message content
    final compressed = await _compression.compressMessage(message);

    // 2. Calculate priority
    final priority = _calculatePriority(message);

    // 3. Prepare for queuing
    return QueuedMessage(
        message: compressed,
        priority: priority,
        timestamp: DateTime.now(),
        attempts: 0);
  }

  void _routeToQueue(QueuedMessage message) {
    switch (message.priority) {
      case MessagePriority.high:
        _highPriority.add(message);
        break;
      case MessagePriority.normal:
        _normalPriority.add(message);
        break;
      case MessagePriority.low:
        _lowPriority.add(message);
        break;
    }
  }

  Future<void> _processBatch() async {
    try {
      // 1. Process high priority first
      await _processPriorityBatch(_highPriority);

      // 2. Then normal priority
      if (_highPriority.isEmpty) {
        await _processPriorityBatch(_normalPriority);
      }

      // 3. Finally low priority
      if (_highPriority.isEmpty && _normalPriority.isEmpty) {
        await _processPriorityBatch(_lowPriority);
      }

      _metrics.batchProcessed();
    } catch (e) {
      _logger.error('Batch processing failed: $e');
      await _handleBatchFailure();
    }
  }

  Future<void> _processPriorityBatch(PriorityQueue<QueuedMessage> queue) async {
    if (queue.isEmpty) return;

    final batch = <QueuedMessage>[];

    // Collect batch
    while (batch.length < BATCH_SIZE && queue.isNotEmpty) {
      batch.add(queue.removeFirst());
    }

    // Process batch
    await Future.wait(batch.map((m) => _processMessage(m)));
  }

  Future<void> _processMessage(QueuedMessage message) async {
    try {
      // 1. Decompress if needed
      final decompressed =
          await _compression.decompressIfNeeded(message.message);

      // 2. Process message
      await _db.saveMessage(decompressed);

      _metrics.messageProcessed();
    } catch (e) {
      _logger.error('Message processing failed: $e');
      await _handleMessageFailure(message);
    }
  }

  MessagePriority _calculatePriority(Message message) {
    if (message.isEmergency) return MessagePriority.high;
    if (message.isSystem) return MessagePriority.high;
    if (message.isAdmin) return MessagePriority.normal;
    return MessagePriority.low;
  }
}
