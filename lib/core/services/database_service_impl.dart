import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:injectable/injectable.dart';
import '../interfaces/database_service.dart';
import '../interfaces/logger_service.dart';
import '../interfaces/json_serializable.dart';

@Singleton(as: IDatabaseService)
class DatabaseService implements IDatabaseService {
  static const String _dbName = 'app.db';
  static const int _version = 1;

  final ILoggerService _logger;
  Database? _db;
  bool _isPaused = false;
  final _connectionController = StreamController<bool>.broadcast();

  // Mapa factory funkcija za deserijalizaciju
  final _deserializers = <Type, Function(Map<String, dynamic>)>{};

  DatabaseService(this._logger);

  /// Registruje factory funkciju za deserijalizaciju tipa T
  void registerDeserializer<T>(T Function(Map<String, dynamic>) fromJson) {
    _deserializers[T] = fromJson;
  }

  @override
  Future<void> initialize() async {
    try {
      final databasePath = await getDatabasesPath();
      final path = join(databasePath, _dbName);

      _db = await openDatabase(
        path,
        version: _version,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onConfigure: _onConfigure,
      );

      _connectionController.add(true);
      _logger.info('Database initialized successfully');
    } catch (e, stackTrace) {
      _logger.error('Failed to initialize database', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS key_value_store (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        type TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // TODO: Implementirati migracije kada dodamo nove verzije
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  @override
  Future<void> dispose() async {
    await _connectionController.close();
    await _db?.close();
    _db = null;
  }

  @override
  Future<void> reconnect() async {
    if (_db != null) return;
    await initialize();
  }

  @override
  Future<void> pause() async {
    _isPaused = true;
    await _db?.close();
    _db = null;
    _connectionController.add(false);
  }

  @override
  Future<void> resume() async {
    if (!_isPaused) return;
    _isPaused = false;
    await reconnect();
  }

  @override
  Future<T?> get<T>(String key) async {
    _ensureInitialized();

    final result = await _db!.query(
      'key_value_store',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (result.isEmpty) return null;

    final row = result.first;
    return _deserialize<T>(row['value'] as String, row['type'] as String);
  }

  @override
  Future<void> set<T>(String key, T value) async {
    _ensureInitialized();

    final now = DateTime.now().millisecondsSinceEpoch;
    final serialized = _serialize(value);

    await _db!.insert(
      'key_value_store',
      {
        'key': key,
        'value': serialized.value,
        'type': serialized.type,
        'created_at': now,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> delete(String key) async {
    _ensureInitialized();

    await _db!.delete(
      'key_value_store',
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  @override
  Future<void> clear() async {
    _ensureInitialized();
    await _db!.delete('key_value_store');
  }

  @override
  Future<List<String>> keys() async {
    _ensureInitialized();

    final result = await _db!.query(
      'key_value_store',
      columns: ['key'],
    );

    return result.map((row) => row['key'] as String).toList();
  }

  @override
  Future<List<T>> values<T>() async {
    _ensureInitialized();

    final result = await _db!.query('key_value_store');

    return result
        .where((row) => _isTypeMatch<T>(row['type'] as String))
        .map((row) => _deserialize<T>(
              row['value'] as String,
              row['type'] as String,
            )!)
        .toList();
  }

  @override
  Future<void> batch(List<Future<void> Function()> operations) async {
    _ensureInitialized();

    await _db!.transaction((txn) async {
      try {
        for (final operation in operations) {
          await operation();
        }
      } catch (e, stackTrace) {
        _logger.error('Batch operation failed', e, stackTrace);
        rethrow;
      }
    });
  }

  @override
  Future<T> transaction<T>(Future<T> Function() operation) async {
    _ensureInitialized();
    return _db!.transaction((txn) => operation());
  }

  @override
  Future<void> migrate() async {
    // Migracije se automatski izvršavaju kroz onUpgrade callback
    _logger.info('No pending migrations');
  }

  @override
  Future<bool> isHealthy() async {
    if (_db == null) return false;

    try {
      await _db!.query('key_value_store', limit: 1);
      return true;
    } catch (e) {
      _logger.error('Database health check failed', e);
      return false;
    }
  }

  void _ensureInitialized() {
    if (_db == null) {
      throw StateError('Database not initialized. Call initialize() first.');
    }
  }

  _SerializedValue _serialize(dynamic value) {
    if (value == null) {
      return _SerializedValue('null', 'null');
    }

    if (value is num || value is bool || value is String) {
      return _SerializedValue(value.toString(), value.runtimeType.toString());
    }

    if (value is JsonSerializable) {
      return _SerializedValue(
        jsonEncode(value.toJson()),
        value.runtimeType.toString(),
      );
    }

    throw UnsupportedError(
      'Type ${value.runtimeType} must implement JsonSerializable or be a basic type',
    );
  }

  T? _deserialize<T>(String value, String type) {
    if (type == 'null') return null;

    try {
      switch (T) {
        case int:
          return int.parse(value) as T;
        case double:
          return double.parse(value) as T;
        case bool:
          return (value == 'true') as T;
        case String:
          return value as T;
        default:
          if (value == 'null') return null;

          try {
            final json = jsonDecode(value);
            if (json is T) return json;

            if (json is Map<String, dynamic>) {
              // Koristi registrovanu factory funkciju
              final deserializer = _deserializers[T];
              if (deserializer != null) {
                return deserializer(json) as T;
              }
            }

            throw UnsupportedError(
              'No deserializer registered for type $T. Use registerDeserializer() first.',
            );
          } catch (e) {
            _logger.error('Failed to deserialize value of type $T', e);
            return null;
          }
      }
    } catch (e) {
      _logger.error('Failed to deserialize value of type $T', e);
      return null;
    }
  }

  bool _isTypeMatch<T>(String type) {
    return type == T.toString();
  }
}

class _SerializedValue {
  final String value;
  final String type;

  _SerializedValue(this.value, this.type);
}
