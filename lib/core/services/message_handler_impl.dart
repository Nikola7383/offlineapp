import 'dart:async';
import '../interfaces/message_handler.dart';
import '../interfaces/logger.dart';
import '../models/message.dart';
import '../models/result.dart';
import '../errors/app_error.dart';
import '../config/app_config.dart';
import 'base_service_impl.dart';

class MessageHandlerImpl extends BaseServiceImpl implements MessageHandler {
  final _messageController = StreamController<Message>.broadcast();
  final _processingQueue = <Message>[];
  Timer? _batchTimer;
  bool _isProcessing = false;

  MessageHandlerImpl(Logger logger) : super(logger);

  @override
  String get serviceId => 'MessageHandler';

  @override
  Stream<Message> get messageStream => _messageController.stream;

  @override
  Future<Result<void>> handleMessage(Message message) async {
    return wrapOperation('handleMessage', () async {
      _processingQueue.add(message);
      _messageController.add(message.copyWith(status: MessageStatus.pending));

      if (_processingQueue.length >= AppConfig.messageBatchSize) {
        await _processBatch();
      }

      return Result.success();
    }).catchError((error, stackTrace) {
      return Result.failure(error.toString(), stackTrace);
    });
  }

  @override
  Future<Result<void>> handleBatch(List<Message> messages) async {
    return wrapOperation('handleBatch', () async {
      _processingQueue.addAll(messages);
      for (final message in messages) {
        _messageController.add(message.copyWith(status: MessageStatus.pending));
      }

      await _processBatch();
      return Result.success();
    }).catchError((error, stackTrace) {
      return Result.failure(error.toString(), stackTrace);
    });
  }

  Future<void> _processBatch() async {
    if (_isProcessing || _processingQueue.isEmpty) return;

    try {
      _isProcessing = true;
      final batch = _processingQueue.take(AppConfig.messageBatchSize).toList();

      // Update status to sending
      for (final message in batch) {
        _messageController.add(message.copyWith(status: MessageStatus.sending));
      }

      // Simulate network delay
      await Future.delayed(AppConfig.retryDelay);

      // Update status to sent
      for (final message in batch) {
        _messageController.add(message.copyWith(status: MessageStatus.sent));
      }

      _processingQueue.removeRange(0, batch.length);
    } catch (e, stackTrace) {
      // Update status to failed
      for (final message in _processingQueue) {
        _messageController.add(message.copyWith(status: MessageStatus.failed));
      }
      throw AppError('Batch processing failed', e, stackTrace);
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Future<void> onInitialize() async {
    _batchTimer = Timer.periodic(
      AppConfig.batchProcessInterval,
      (_) => _processBatch(),
    );
  }

  @override
  Future<void> onDispose() async {
    _batchTimer?.cancel();
    await _messageController.close();
    _processingQueue.clear();
  }
}
