import '../models/sync_models.dart';
import '../models/message.dart';

/// Interfejs za sinhronizaciju
abstract class ISyncService extends IService {
  /// Stream sinhronizacionih događaja
  Stream<SyncEvent> get syncStream;

  /// Status sinhronizacije
  SyncStatus get status;

  /// Manuelno pokreće sinhronizaciju
  Future<Result<void>> sync();

  /// Dodaje poruku u queue za sinhronizaciju
  Future<Result<void>> queueMessage(Message message);

  /// Briše poruku iz queue-a
  Future<Result<void>> removeFromQueue(String messageId);

  /// Vraća poruke koje čekaju na sinhronizaciju
  Future<Result<List<Message>>> getPendingMessages();

  /// Čisti queue
  Future<Result<void>> clearQueue();
}
