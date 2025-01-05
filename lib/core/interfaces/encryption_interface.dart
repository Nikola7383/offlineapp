abstract class EncryptionInterface extends BaseInterface {
  Future<Message> encrypt(Message message);
  Future<Message> decrypt(Message message);
  Future<bool> verifyMessage(Message message);
}
