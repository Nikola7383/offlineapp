import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import '../interfaces/database_service.dart';
import '../interfaces/logger_service.dart';
import '../models/database_models.dart';
import '../models/result.dart';
import '../models/service_error.dart';
import 'base_service.dart';

class DatabaseService extends BaseService implements IDatabaseService {
  final Map<String, dynamic> _storage = {};
  final DatabaseConfig config;

  DatabaseService(this.config);

  @override
  Future<void> onInitialize() async {
    // Ovde bi išla inicijalizacija prave baze
    // Za sada samo simuliramo
  }

  @override
  Future<void> onDispose() async {
    _storage.clear();
  }

  @override
  Future<Result<T?>> get<T>(String key) async {
    try {
      return Result.success(_storage[key] as T?);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<void>> set<T>(String key, T value) async {
    try {
      _storage[key] = value;
      return Result.success();
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, T>>> getAll<T>(String prefix) async {
    try {
      final result = <String, T>{};
      for (final entry in _storage.entries) {
        if (entry.key.startsWith(prefix)) {
          result[entry.key] = entry.value as T;
        }
      }
      return Result.success(result);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<void>> delete(String key) async {
    try {
      _storage.remove(key);
      return Result.success();
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<void>> clear() async {
    try {
      _storage.clear();
      return Result.success();
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}

class DatabaseConfig {
  final String name;
  final bool encryptionEnabled;

  const DatabaseConfig({
    required this.name,
    this.encryptionEnabled = false,
  });
}
