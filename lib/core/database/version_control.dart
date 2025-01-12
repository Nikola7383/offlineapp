import 'package:injectable/injectable.dart';

@injectable
class DatabaseVersionControl extends InjectableService {
  static const String VERSION_TABLE = 'schema_versions';
  final DatabaseService _db;

  DatabaseVersionControl(LoggerService logger, this._db) : super(logger);

  Future<void> initialize() async {
    await _createVersionTable();
    await _runMigrations();
  }

  Future<void> _createVersionTable() async {
    final db = await _db.database;
    await db.execute(
        '''
      CREATE TABLE IF NOT EXISTS $VERSION_TABLE (
        version INTEGER PRIMARY KEY,
        applied_at INTEGER NOT NULL,
        description TEXT,
        checksum TEXT
      )
    ''');
  }

  Future<void> _runMigrations() async {
    final currentVersion = await _getCurrentVersion();
    final migrations = _getMigrations();

    for (final migration in migrations) {
      if (migration.version > currentVersion) {
        await _applyMigration(migration);
      }
    }
  }

  Future<int> _getCurrentVersion() async {
    final db = await _db.database;
    final result = await db.query(
      VERSION_TABLE,
      orderBy: 'version DESC',
      limit: 1,
    );

    return result.isEmpty ? 0 : result.first['version'] as int;
  }

  Future<void> _applyMigration(DatabaseMigration migration) async {
    final db = await _db.database;

    await db.transaction((txn) async {
      // Primeni migraciju
      await migration.up(txn);

      // Zabeleži primenjenu migraciju
      await txn.insert(VERSION_TABLE, {
        'version': migration.version,
        'applied_at': DateTime.now().millisecondsSinceEpoch,
        'description': migration.description,
        'checksum': migration.checksum,
      });
    });

    logger.info('Applied migration: ${migration.version}');
  }
}

abstract class DatabaseMigration {
  final int version;
  final String description;
  final String checksum;

  DatabaseMigration({
    required this.version,
    required this.description,
    required this.checksum,
  });

  Future<void> up(Transaction txn);
  Future<void> down(Transaction txn);
}
