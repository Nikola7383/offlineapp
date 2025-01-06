class ChatHistoryManager {
  final SecureStorage _storage;
  final EncryptionService _encryption;
  final LoggingService _logger;

  ChatHistoryManager(this._storage, this._encryption, this._logger);

  Future<void> saveChat(String sessionId, List<ChatMessage> messages) async {
    try {
      // Prvo učitamo postojeću istoriju
      final existingMessages = await loadChat(sessionId);

      // Dodamo nove poruke
      final allMessages = [...existingMessages, ...messages];

      // Enkriptujemo i čuvamo
      final encryptedData = await _encryption
          .encrypt(jsonEncode(allMessages.map((m) => m.toJson()).toList()));

      await _storage.write(
          key: 'chat_history_$sessionId', value: encryptedData);

      // Logujemo uspešno čuvanje
      _logger.info('Chat history saved for session $sessionId');
    } catch (e) {
      _logger.error('Failed to save chat history: $e');
      throw ChatHistoryException('Failed to save chat history');
    }
  }

  Future<List<ChatMessage>> loadChat(String sessionId) async {
    try {
      final encryptedData = await _storage.read(key: 'chat_history_$sessionId');
      if (encryptedData == null) return [];

      final decryptedData = await _encryption.decrypt(encryptedData);
      final List<dynamic> jsonList = jsonDecode(decryptedData);

      return jsonList.map((json) => ChatMessage.fromJson(json)).toList();
    } catch (e) {
      _logger.error('Failed to load chat history: $e');
      throw ChatHistoryException('Failed to load chat history');
    }
  }

  Future<List<String>> listSessions() async {
    try {
      final allKeys = await _storage.getAllKeys();
      return allKeys.where((key) => key.startsWith('chat_history_')).toList();
    } catch (e) {
      _logger.error('Failed to list sessions: $e');
      throw ChatHistoryException('Failed to list sessions');
    }
  }

  // Metoda za export istorije (samo čitanje)
  Future<String> exportHistory(String sessionId) async {
    try {
      final messages = await loadChat(sessionId);
      return jsonEncode({
        'sessionId': sessionId,
        'timestamp': DateTime.now().toIso8601String(),
        'messages': messages.map((m) => m.toJson()).toList(),
      });
    } catch (e) {
      _logger.error('Failed to export history: $e');
      throw ChatHistoryException('Failed to export history');
    }
  }

  // Metoda za backup cele istorije
  Future<void> backupAllHistory() async {
    try {
      final sessions = await listSessions();
      final allHistory = <String, List<ChatMessage>>{};

      for (final sessionId in sessions) {
        allHistory[sessionId] = await loadChat(sessionId);
      }

      final backupData = await _encryption.encrypt(jsonEncode(allHistory));
      await _storage.write(
          key: 'history_backup_${DateTime.now().toIso8601String()}',
          value: backupData);

      _logger.info('Complete history backup created');
    } catch (e) {
      _logger.error('Failed to backup history: $e');
      throw ChatHistoryException('Failed to backup history');
    }
  }
}

// Custom exception
class ChatHistoryException implements Exception {
  final String message;
  ChatHistoryException(this.message);

  @override
  String toString() => 'ChatHistoryException: $message';
}
