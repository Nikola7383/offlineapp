abstract class MeshInterface extends BaseInterface {
  Stream<Message> get messageStream;
  Set<String> get connectedPeers;
  Future<void> start();
  Future<bool> broadcast(Message message);
  Future<void> stop();
}
