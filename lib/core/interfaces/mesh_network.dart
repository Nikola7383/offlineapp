import 'base_service.dart';

/// Interfejs za mesh mrežu
abstract class IMeshNetwork implements IAsyncService, IStateService {
  /// Šalje poruku na datu temu
  Future<void> broadcast(String topic, dynamic message);

  /// Pretplaćuje se na temu
  Stream<dynamic> subscribe(String topic);

  /// Vraća listu aktivnih peer-ova
  Future<List<String>> getActivePeers();

  /// Vraća informacije o peer-u
  Future<PeerInfo?> getPeerInfo(String peerId);

  /// Šalje direktnu poruku peer-u
  Future<void> sendToPeer(String peerId, dynamic message);

  /// Stream za primanje direktnih poruka
  Stream<PeerMessage> get directMessages;

  /// Stream za praćenje promene peer-ova
  Stream<List<String>> get peerUpdates;
}

/// Informacije o peer-u
class PeerInfo {
  /// ID peer-a
  final String id;

  /// Adresa peer-a
  final String address;

  /// Tip peer-a
  final PeerType type;

  /// Metadata peer-a
  final Map<String, dynamic> metadata;

  /// Kreira nove informacije o peer-u
  PeerInfo({
    required this.id,
    required this.address,
    required this.type,
    this.metadata = const {},
  });
}

/// Tip peer-a
enum PeerType {
  /// Standardni peer
  standard,

  /// Super peer (relay)
  relay,

  /// Edge peer (ograničeni resursi)
  edge
}

/// Poruka od peer-a
class PeerMessage {
  /// ID pošiljaoca
  final String senderId;

  /// Sadržaj poruke
  final dynamic content;

  /// Vreme slanja
  final DateTime timestamp;

  /// Kreira novu peer poruku
  PeerMessage({
    required this.senderId,
    required this.content,
    required this.timestamp,
  });
}
