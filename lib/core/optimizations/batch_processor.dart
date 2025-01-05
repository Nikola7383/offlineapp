import 'dart:async';
import 'dart:math' show min;
import 'package:sqflite/sqflite.dart';
import '../database/database_service.dart';
import '../database/connection_pool.dart';
import '../services/logger_service.dart';
import '../models/message.dart';
import 'package:injectable/injectable.dart';

@injectable
class BatchProcessor extends InjectableService implements Disposable {
  final Queue<Message> _messageQueue = Queue();
  Timer? _batchTimer;
  static const int MAX_BATCH_SIZE = 100;
  static const Duration BATCH_WINDOW = Duration(milliseconds: 100);

  BatchProcessor(LoggerService logger) : super(logger);

  @override
  Future<void> initialize() async {
    await super.initialize();
    ServiceLocator.instance
        .get<ResourceManager>()
        .register('batch_processor', this);
  }

  @override
  Future<void> dispose() async {
    _batchTimer?.cancel();
    await _processBatch(); // Process remaining messages
    await super.dispose();
  }

  Future<void> addMessage(Message message) async {
    _messageQueue.add(message);

    if (_messageQueue.length >= MAX_BATCH_SIZE) {
      await _processBatch();
    } else if (_batchTimer == null) {
      _batchTimer = Timer(BATCH_WINDOW, () async {
        await _processBatch();
      });
    }
  }

  Future<void> processBatch(List<Message> messages) async {
    try {
      final connection = await DatabasePool().acquire();

      await connection.transaction((txn) async {
        for (final chunk in _chunks(messages, 100)) {
          await Future.wait(
            chunk.map((msg) => txn.insert(
                  'messages',
                  msg.toMap(),
                  conflictAlgorithm: ConflictAlgorithm.replace,
                )),
          );
        }
      });

      DatabasePool().release(connection);
    } catch (e, stack) {
      _logger.error('Greška pri batch procesiranju', e, stack);
      rethrow;
    }
  }

  Iterable<List<T>> _chunks<T>(List<T> list, int size) sync* {
    for (var i = 0; i < list.length; i += size) {
      yield list.sublist(i, min(i + size, list.length));
    }
  }
}
