import 'package:injectable/injectable.dart';

@injectable
class IndexManager extends InjectableService {
  final DatabaseService _db;
  final Map<String, Index> _indexes = {};

  IndexManager(LoggerService logger, this._db) : super(logger);

  @override
  Future<void> initialize() async {
    await super.initialize();
    await _createIndexes();
  }

  Future<void> _createIndexes() async {
    final indexes = [
      Index(
        name: 'idx_messages_timestamp',
        table: 'messages',
        columns: ['timestamp'],
      ),
      Index(
        name: 'idx_messages_sender_status',
        table: 'messages',
        columns: ['sender_id', 'status'],
      ),
      Index(
        name: 'idx_users_username',
        table: 'users',
        columns: ['username'],
        unique: true,
      ),
    ];

    for (final index in indexes) {
      await _createIndex(index);
      _indexes[index.name] = index;
    }
  }

  Future<void> _createIndex(Index index) async {
    final db = await _db.database;
    await db.execute(
        '''
      CREATE ${index.unique ? 'UNIQUE' : ''} INDEX IF NOT EXISTS 
      ${index.name} ON ${index.table} 
      (${index.columns.join(', ')})
    ''');
  }
}

class Index {
  final String name;
  final String table;
  final List<String> columns;
  final bool unique;

  Index({
    required this.name,
    required this.table,
    required this.columns,
    this.unique = false,
  });
}
