import 'dart:async';
import '../interfaces/storage_service.dart';
import '../interfaces/logger_service.dart';
import '../models/message.dart';
import '../models/result.dart';
import '../models/service_error.dart';
import 'base_service.dart';

class StorageService extends BaseService implements IStorageService {
  final IDatabaseService _database;
  final Map<String, Message> _cache = {};

  StorageService(this._database);

  @override
  Future<void> onInitialize() async {
    // Učitamo sve poruke u cache pri inicijalizaciji
    await getMessages();
  }

  @override
  Future<Result<void>> saveMessage(Message message) async {
    try {
      // Sačuvamo u bazu
      final result =
          await _database.set('messages/${message.id}', message.toJson());
      if (!result.isSuccess) return result;

      // Ažuriramo cache
      _cache[message.id] = message;
      return Result.success();
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<List<Message>>> getMessages() async {
    try {
      // Učitamo iz baze ako je cache prazan
      if (_cache.isEmpty) {
        final result =
            await _database.getAll<Map<String, dynamic>>('messages/');
        if (!result.isSuccess) return Result.failure(result.error!);

        _cache.clear();
        for (final entry in result.data!.entries) {
          _cache[entry.key] = Message.fromJson(entry.value);
        }
      }

      return Result.success(_cache.values.toList());
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}
