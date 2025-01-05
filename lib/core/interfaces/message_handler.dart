import '../models/message.dart';
import '../models/result.dart';

abstract class MessageHandler {
  Future<Result<void>> handleMessage(Message message);
  Future<Result<void>> handleBatch(List<Message> messages);
  Stream<Message> get messageStream;
}
