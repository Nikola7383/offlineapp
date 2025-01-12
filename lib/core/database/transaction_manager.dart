import 'package:injectable/injectable.dart';
import 'package:synchronized/synchronized.dart';
import 'package:uuid/uuid.dart';
import '../services/logger_service.dart';
import '../services/database_service.dart';
import '../interfaces/base_service.dart';

@injectable
class TransactionManager extends InjectableService implements Disposable {
  final DatabaseService _db;
  final _activeTransactions = <String, Transaction>{};
  final _transactionLock = Lock();

  TransactionManager(
    LoggerService logger,
    this._db,
  ) : super(logger);

  Future<T> runInTransaction<T>(Future<T> Function(Transaction) action,
      {String? transactionId}) async {
    final txId = transactionId ?? Uuid().v4();

    return await _transactionLock.synchronized(() async {
      try {
        final db = await _db.database;
        final transaction = await db.transaction((txn) async {
          _activeTransactions[txId] = txn;
          try {
            final result = await action(txn);
            return result;
          } finally {
            _activeTransactions.remove(txId);
          }
        });
        return transaction;
      } catch (e, stack) {
        logger.error('Transaction error: $txId', e, stack);
        rethrow;
      }
    });
  }
}
