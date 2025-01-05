import 'dart:async';
import '../interfaces/sync_service.dart';
import '../interfaces/logger_service.dart';
import '../interfaces/mesh_service.dart';
import '../interfaces/storage_service.dart';
import '../interfaces/connection_service.dart';
import '../models/sync_models.dart';
import '../models/message.dart';
import '../models/result.dart';
import 'base_service.dart';

class SyncService extends BaseService implements ISyncService {
  final IMeshService _meshService;
  final IStorageService _storageService;
  final Map<String, Message> _pendingMessages = {};

  SyncService(this._meshService, this._storageService);

  @override
  Future<void> onInitialize() async {
    final result = await _storageService.getMessages();
    if (result.isSuccess) {
      for (final message in result.data!) {
        if (message.status == MessageStatus.pending ||
            message.status == MessageStatus.failed) {
          _pendingMessages[message.id] = message;
        }
      }
    }
  }

  @override
  Future<Result<void>> queueMessage(Message message) async {
    try {
      final messageToSave = Message(
        id: message.id,
        content: message.content,
        senderId: message.senderId,
        timestamp: message.timestamp,
        status: MessageStatus.pending,
      );

      final saveResult = await _storageService.saveMessage(messageToSave);
      if (!saveResult.isSuccess) {
        return saveResult;
      }

      _pendingMessages[message.id] = messageToSave;
      return Result.success();
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<void>> sync() async {
    if (_pendingMessages.isEmpty) return Result.success();

    var hasSuccess = false;
    final List<String> processedIds = [];

    for (final message in _pendingMessages.values) {
      try {
        await _updateMessageStatus(message, MessageStatus.sending);

        final result = await _meshService.sendMessage(message);
        if (result.isSuccess) {
          await _updateMessageStatus(message, MessageStatus.sent);
          processedIds.add(message.id);
          hasSuccess = true;
        } else {
          await _updateMessageStatus(message, MessageStatus.failed);
        }
      } catch (e) {
        await _updateMessageStatus(message, MessageStatus.failed);
      }
    }

    for (final id in processedIds) {
      _pendingMessages.remove(id);
    }

    return hasSuccess ? Result.success() : Result.failure('Sync failed');
  }

  Future<void> _updateMessageStatus(
      Message message, MessageStatus status) async {
    final updatedMessage = Message(
      id: message.id,
      content: message.content,
      senderId: message.senderId,
      timestamp: message.timestamp,
      status: status,
    );

    await _storageService.saveMessage(updatedMessage);
    if (status == MessageStatus.pending || status == MessageStatus.failed) {
      _pendingMessages[message.id] = updatedMessage;
    }
  }

  @override
  Future<Result<List<Message>>> getPendingMessages() async {
    return Result.success(_pendingMessages.values.toList());
  }

  @override
  Future<Result<void>> clearQueue() async {
    _pendingMessages.clear();
    return Result.success();
  }
}
