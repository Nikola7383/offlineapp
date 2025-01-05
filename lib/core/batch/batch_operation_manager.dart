import 'dart:async';
import '../models/message.dart';
import '../mesh/mesh_network.dart';
import '../logging/logger_service.dart';
import '../config/app_config.dart';

class BatchOperationManager {
  final MeshNetwork _meshNetwork;
  final LoggerService _logger;
  final List<Message> _messageQueue = [];
  Timer? _batchTimer;
  bool _isProcessing = false;

  BatchOperationManager({
    required MeshNetwork meshNetwork,
    required LoggerService logger,
  })  : _meshNetwork = meshNetwork,
        _logger = logger {
    _startBatchProcessor();
  }

  void _startBatchProcessor() {
    _batchTimer = Timer.periodic(
      AppConfig.batchProcessInterval,
      (_) => _processBatch(),
    );
  }

  Future<void> queueMessage(Message message) async {
    _messageQueue.add(message);
    await _logger.info('Message queued: ${message.id}');

    if (_messageQueue.length >= AppConfig.messageBatchSize) {
      await _processBatch();
    }
  }

  Future<void> _processBatch() async {
    if (_isProcessing || _messageQueue.isEmpty) return;

    try {
      _isProcessing = true;
      final batch = _messageQueue.take(AppConfig.messageBatchSize).toList();

      await _meshNetwork.sendBatch(batch);

      _messageQueue.removeRange(0, batch.length);
      await _logger.info('Processed batch of ${batch.length} messages');
    } catch (e) {
      await _logger.error('Batch processing failed', e);
    } finally {
      _isProcessing = false;
    }
  }

  void dispose() {
    _batchTimer?.cancel();
    _messageQueue.clear();
  }
}
