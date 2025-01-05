abstract class DatabaseInterface extends BaseInterface {
  Future<void> saveMessage(Message message);
  Future<List<Message>> getMessages({
    DateTime? since,
    int limit = 50,
    String? senderId,
  });
  Future<bool> messageExists(String id);
  Future<void> deleteMessage(String id);
  Future<int> getDatabaseSize();
  Future<void> close();
  Future<bool> checkIntegrity();
  Future<bool> repair();
}
