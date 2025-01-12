import 'base_service.dart';
import '../models/message.dart';
import '../models/message_types.dart';

/// Interfejs za mesh mrežu
abstract class MeshNetwork implements IAsyncService {
  /// Šalje poruku kroz mrežu
  Future<bool> broadcast(Message message);

  /// Prosleđuje poruku dalje
  Future<void> relay(Message message);

  /// Stream za primanje poruka
  Stream<Message> get incomingMessages;

  /// Vraća status mreže
  Future<MeshNetworkStatus> getNetworkStatus();

  /// Stream za praćenje statusa mreže
  Stream<MeshNetworkStatus> get networkStatusStream;
}

/// Status mesh mreže
class MeshNetworkStatus {
  /// Da li je povezan
  final bool isConnected;

  /// Broj aktivnih čvorova
  final int activeNodes;

  /// Veličina reda za poruke
  final int messageQueueSize;

  /// Vreme poslednje aktivnosti
  final DateTime lastActivity;

  /// Da li je mreža zdrava
  bool get isHealthy => isConnected && activeNodes > 0;

  /// Kreira novi status
  MeshNetworkStatus({
    required this.isConnected,
    required this.activeNodes,
    required this.messageQueueSize,
    required this.lastActivity,
  });
}
