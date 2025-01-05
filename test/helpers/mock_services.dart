import 'package:mockito/mockito.dart';
import 'package:secure_event_app/core/interfaces/database_service.dart';
import 'package:secure_event_app/core/interfaces/logger_service.dart';
import 'package:secure_event_app/core/interfaces/mesh_service.dart';
import 'package:secure_event_app/core/interfaces/storage_service.dart';
import 'package:secure_event_app/core/models/result.dart';

class MockDatabaseService extends Mock implements IDatabaseService {
  final Map<String, dynamic> _storage = {};
  bool _isInitialized = false;

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    _storage.clear();
    _isInitialized = false;
  }

  @override
  Future<Result<void>> clear() async {
    _storage.clear();
    return Result.success();
  }

  @override
  Future<Result<void>> set<T>(String key, T value) async {
    _storage[key] = value;
    return Result.success();
  }

  @override
  Future<Result<T?>> get<T>(String key) async {
    return Result.success(_storage[key] as T?);
  }

  @override
  Future<Result<Map<String, T>>> getAll<T>(String prefix) async {
    final result = <String, T>{};
    for (final entry in _storage.entries) {
      if (entry.key.startsWith(prefix)) {
        result[entry.key] = entry.value as T;
      }
    }
    return Result.success(result);
  }
}

class MockMeshService extends Mock implements IMeshService {
  bool _isInitialized = false;
  bool simulateNetworkError = false;

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    _isInitialized = false;
  }

  @override
  Future<Result<void>> sendMessage(Message message) async {
    if (simulateNetworkError) {
      return Result.failure('Network error');
    }
    return Result.success();
  }
}

class MockLoggerService extends Mock implements ILoggerService {
  @override
  Future<void> info(String message, [Map<String, dynamic>? data]) async {}

  @override
  Future<void> error(String message, [Map<String, dynamic>? data]) async {}
}

class MockStorageService extends Mock implements IStorageService {
  final Map<String, Message> _messages = {};

  @override
  Future<Result<void>> saveMessage(Message message) async {
    _messages[message.id] = message;
    return Result.success();
  }

  @override
  Future<Result<List<Message>>> getMessages() async {
    return Result.success(_messages.values.toList());
  }
}
