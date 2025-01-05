import 'node.dart';

abstract class ProtocolManager {
  /// Skenira i vraća listu dostupnih uređaja
  Future<List<Node>> scanForDevices();

  /// Šalje podatke određenom uređaju
  Future<bool> sendData(String nodeId, List<int> data);

  /// Počinje slušanje dolaznih konekcija
  Future<void> startListening();

  /// Zaustavlja slušanje i čisti konekcije
  Future<void> stopListening();
}
