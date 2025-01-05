import '../models/message.dart';
import '../models/result.dart';

/// Interfejs za mesh networking
abstract class IMeshService extends IService {
  /// Šalje pojedinačnu poruku
  Future<Result<void>> sendMessage(Message message);

  /// Šalje batch poruka
  Future<Result<void>> sendBatch(List<Message> messages);

  /// Stream za primanje poruka
  Stream<Message> get messageStream;

  /// Trenutni status konekcije
  bool get isConnected;

  /// Povezuje konekciju
  Future<Result<void>> connect();

  /// Prekida konekciju
  Future<Result<void>> disconnect();
}
