import '../models/message.dart';
import '../storage/database_service.dart';
import '../config/app_config.dart';
import '../logging/logger_service.dart';

class LazyMessageLoader {
  final DatabaseService _storage;
  final LoggerService _logger;
  bool _isLoading = false;
  int _currentPage = 0;
  final List<Message> _loadedMessages = [];

  LazyMessageLoader({
    required DatabaseService storage,
    required LoggerService logger,
  })  : _storage = storage,
        _logger = logger;

  Future<List<Message>> loadNextBatch() async {
    if (_isLoading) return _loadedMessages;

    try {
      _isLoading = true;

      final offset = _currentPage * AppConfig.messageBatchSize;
      final messages = await _storage.getMessages(
        limit: AppConfig.messageBatchSize,
        offset: offset,
      );

      if (messages.isNotEmpty) {
        _loadedMessages.addAll(messages);
        _currentPage++;
        _logger.info('Loaded message batch: ${messages.length} messages');
      }

      return _loadedMessages;
    } catch (e) {
      _logger.error('Failed to load messages', e);
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  Future<void> refreshMessages() async {
    _loadedMessages.clear();
    _currentPage = 0;
    await loadNextBatch();
  }

  bool get hasMoreMessages =>
      _loadedMessages.length % AppConfig.messageBatchSize == 0;

  List<Message> get currentMessages => List.unmodifiable(_loadedMessages);
}
