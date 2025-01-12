import 'package:injectable/injectable.dart';

@injectable
class MigrationManager extends InjectableService {
  final DatabaseService _db;
  final Map<int, Migration> _migrations = {};

  MigrationManager(LoggerService logger, this._db) : super(logger) {
    _registerMigrations();
  }

  void _registerMigrations() {
    _migrations[1] = InitialMigration();
    _migrations[2] = AddIndexesMigration();
    // Dodati nove migracije ovde
  }

  Future<void> migrate() async {
    final db = await _db.database;
    final currentVersion = await _getCurrentVersion(db);
    final targetVersion = _migrations.keys.reduce(max);

    for (var version = currentVersion + 1;
        version <= targetVersion;
        version++) {
      final migration = _migrations[version];
      if (migration != null) {
        await _runMigration(db, migration, version);
      }
    }
  }

  Future<void> _runMigration(
      Database db, Migration migration, int version) async {
    await db.transaction((txn) async {
      await migration.up(txn);
      await txn.execute(
        'INSERT OR REPLACE INTO schema_migrations (version) VALUES (?)',
        [version],
      );
    });
    logger.info('Migrated to version $version');
  }
}

abstract class Migration {
  Future<void> up(Transaction txn);
  Future<void> down(Transaction txn);
}
