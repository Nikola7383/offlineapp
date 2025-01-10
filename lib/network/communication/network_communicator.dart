import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';
import '../../security/encryption/encryption_service.dart';
import '../../mesh/models/node.dart';
import 'bluetooth_connection.dart';
import 'wifi_direct_connection.dart';
import 'sound_connection.dart';

/// Upravlja mrežnom komunikacijom između čvorova
class NetworkCommunicator {
  final EncryptionService _encryptionService;
  final _messageController = StreamController<NetworkMessage>.broadcast();

  // Aktivne konekcije
  final Map<String, NodeConnection> _connections = {};

  // Redovi čekanja za poruke
  final Map<String, Queue<PendingMessage>> _messageQueues = {};

  // Konstante
  static const Duration CONNECTION_TIMEOUT = Duration(seconds: 10);
  static const Duration RETRY_INTERVAL = Duration(seconds: 1);
  static const int MAX_RETRIES = 3;
  static const int MAX_QUEUE_SIZE = 1000;

  Stream<NetworkMessage> get messageStream => _messageController.stream;

  NetworkCommunicator({
    required EncryptionService encryptionService,
  }) : _encryptionService = encryptionService;

  /// Uspostavlja konekciju sa čvorom
  Future<bool> connect(String nodeId) async {
    if (_connections.containsKey(nodeId)) {
      return true; // Već smo povezani
    }

    try {
      // Pokušaj uspostavljanje konekcije
      final connection = await _establishConnection(nodeId);
      if (connection == null) return false;

      _connections[nodeId] = connection;

      // Pokreni obradu poruka u redu čekanja
      _processMessageQueue(nodeId);

      return true;
    } catch (e) {
      print('Greška pri povezivanju sa čvorom $nodeId: $e');
      return false;
    }
  }

  /// Prekida konekciju sa čvorom
  Future<void> disconnect(String nodeId) async {
    final connection = _connections.remove(nodeId);
    if (connection != null) {
      await connection.close();
    }
  }

  /// Šalje ping paket čvoru
  Future<bool> sendPing(String nodeId) async {
    try {
      final message = NetworkMessage(
        type: MessageType.ping,
        sourceId: 'local',
        targetId: nodeId,
        payload: Uint8List(0),
        timestamp: DateTime.now(),
      );

      final success = await _sendMessage(message);
      if (!success) return false;

      // Čekaj odgovor
      final response = await _waitForResponse(
        nodeId,
        MessageType.pong,
        timeout: Duration(seconds: 2),
      );

      return response != null;
    } catch (e) {
      print('Greška pri slanju ping paketa čvoru $nodeId: $e');
      return false;
    }
  }

  /// Šalje podatke čvoru
  Future<bool> sendData(
    String nodeId,
    Uint8List data, {
    Duration? timeout,
  }) async {
    try {
      // Enkriptuj podatke
      final encryptedData = await _encryptionService.encrypt(data.toString());

      final message = NetworkMessage(
        type: MessageType.data,
        sourceId: 'local',
        targetId: nodeId,
        payload: Uint8List.fromList(encryptedData.codeUnits),
        timestamp: DateTime.now(),
      );

      final success = await _sendMessage(
        message,
        timeout: timeout ?? CONNECTION_TIMEOUT,
      );

      return success;
    } catch (e) {
      print('Greška pri slanju podataka čvoru $nodeId: $e');
      return false;
    }
  }

  /// Uspostavlja konekciju sa čvorom
  Future<NodeConnection?> _establishConnection(String nodeId) async {
    // Pokušaj prvo Bluetooth konekciju
    final bluetoothConnection = BluetoothConnection(nodeId: nodeId);
    if (await bluetoothConnection.initialize()) {
      return bluetoothConnection;
    }

    // Ako ne uspe, pokušaj WiFi Direct
    final wifiConnection = WiFiDirectConnection(nodeId: nodeId);
    if (await wifiConnection.initialize()) {
      return wifiConnection;
    }

    // Ako ne uspe, pokušaj zvučnu komunikaciju
    final soundConnection = SoundConnection(nodeId: nodeId);
    if (await soundConnection.initialize()) {
      return soundConnection;
    }

    return null;
  }

  /// Šalje poruku čvoru
  Future<bool> _sendMessage(
    NetworkMessage message, {
    Duration timeout = CONNECTION_TIMEOUT,
  }) async {
    final nodeId = message.targetId;

    // Proveri da li smo povezani
    if (!_connections.containsKey(nodeId)) {
      final connected = await connect(nodeId);
      if (!connected) return false;
    }

    try {
      final connection = _connections[nodeId]!;
      return await connection.send(message);
    } catch (e) {
      print('Greška pri slanju poruke čvoru $nodeId: $e');
      return false;
    }
  }

  /// Čeka odgovor od čvora
  Future<NetworkMessage?> _waitForResponse(
    String nodeId,
    MessageType expectedType, {
    Duration timeout = CONNECTION_TIMEOUT,
  }) async {
    final completer = Completer<NetworkMessage?>();

    // Postavi timer za timeout
    final timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    });

    // Pretplati se na poruke
    final subscription = messageStream.listen((message) {
      if (message.sourceId == nodeId && message.type == expectedType) {
        if (!completer.isCompleted) {
          completer.complete(message);
        }
      }
    });

    try {
      return await completer.future;
    } finally {
      timer.cancel();
      subscription.cancel();
    }
  }

  /// Obrađuje red čekanja poruka za čvor
  void _processMessageQueue(String nodeId) {
    final queue = _messageQueues[nodeId] ??= Queue<PendingMessage>();

    // Pokreni periodičnu obradu
    Timer.periodic(RETRY_INTERVAL, (timer) async {
      if (!_connections.containsKey(nodeId)) {
        timer.cancel();
        return;
      }

      while (queue.isNotEmpty) {
        final pending = queue.first;

        // Pokušaj slanje poruke
        final success = await _sendMessage(pending.message);
        if (success) {
          queue.removeFirst();
          pending.completer.complete(true);
        } else {
          pending.retries++;
          if (pending.retries >= MAX_RETRIES) {
            queue.removeFirst();
            pending.completer.complete(false);
          } else {
            break; // Sačekaj sledeći interval za ponovni pokušaj
          }
        }
      }
    });
  }

  /// Čisti resurse
  void dispose() {
    _messageController.close();
    for (var connection in _connections.values) {
      connection.close();
    }
    _connections.clear();
  }
}

/// Tip poruke
enum MessageType {
  ping,
  pong,
  data,
  ack,
}

/// Mrežna poruka
class NetworkMessage {
  final MessageType type;
  final String sourceId;
  final String targetId;
  final Uint8List payload;
  final DateTime timestamp;

  const NetworkMessage({
    required this.type,
    required this.sourceId,
    required this.targetId,
    required this.payload,
    required this.timestamp,
  });
}

/// Poruka na čekanju
class PendingMessage {
  final NetworkMessage message;
  final Completer<bool> completer;
  int retries = 0;

  PendingMessage({
    required this.message,
    required this.completer,
  });
}

/// Interfejs za mrežnu konekciju sa čvorom
abstract class NodeConnection {
  String get nodeId;
  Future<bool> initialize();
  Future<bool> send(NetworkMessage message);
  Future<void> close();
}
