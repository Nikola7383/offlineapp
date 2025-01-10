import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'network_communicator.dart';

/// Upravlja WiFi Direct konekcijom sa čvorom
class WiFiDirectConnection implements NodeConnection {
  @override
  final String nodeId;

  // Socket konekcija
  Socket? _socket;
  ServerSocket? _server;

  // Stream controller za primljene poruke
  final _messageController = StreamController<NetworkMessage>.broadcast();

  // Status konekcije
  bool _isConnected = false;
  bool _isConnecting = false;

  // Konstante
  static const Duration CONNECT_TIMEOUT = Duration(seconds: 30);
  static const int DEFAULT_PORT = 8888;

  Stream<NetworkMessage> get messageStream => _messageController.stream;
  bool get isConnected => _isConnected;

  WiFiDirectConnection({
    required this.nodeId,
  });

  /// Inicijalizuje WiFi Direct konekciju
  Future<bool> initialize() async {
    try {
      // Prvo pokušaj da se povežeš kao klijent
      final connected = await _connectAsClient();
      if (connected) return true;

      // Ako ne uspe, pokušaj da pokreneš server
      return await _startServer();
    } catch (e) {
      print('Greška pri inicijalizaciji WiFi Direct konekcije: $e');
      return false;
    }
  }

  /// Povezuje se kao klijent
  Future<bool> _connectAsClient() async {
    if (_isConnected) return true;
    if (_isConnecting) return false;

    _isConnecting = true;

    try {
      // Pokušaj uspostaviti konekciju
      _socket = await Socket.connect(
        nodeId,
        DEFAULT_PORT,
        timeout: CONNECT_TIMEOUT,
      );

      // Pretplati se na primanje podataka
      _socket!.listen(
        _handleReceivedData,
        onDone: () {
          _isConnected = false;
          _socket = null;
        },
        onError: (e) {
          print('Greška pri primanju podataka: $e');
          _isConnected = false;
          _socket = null;
        },
      );

      _isConnected = true;
      _isConnecting = false;
      return true;
    } catch (e) {
      print('Greška pri povezivanju kao klijent: $e');
      _isConnected = false;
      _isConnecting = false;
      return false;
    }
  }

  /// Pokreće server
  Future<bool> _startServer() async {
    try {
      // Pokreni server socket
      _server = await ServerSocket.bind(
        InternetAddress.anyIPv4,
        DEFAULT_PORT,
      );

      // Pretplati se na nove konekcije
      _server!.listen((socket) {
        if (_socket != null) {
          // Već imamo konekciju, odbij novu
          socket.close();
          return;
        }

        _socket = socket;
        _isConnected = true;

        // Pretplati se na primanje podataka
        socket.listen(
          _handleReceivedData,
          onDone: () {
            _isConnected = false;
            _socket = null;
          },
          onError: (e) {
            print('Greška pri primanju podataka: $e');
            _isConnected = false;
            _socket = null;
          },
        );
      });

      return true;
    } catch (e) {
      print('Greška pri pokretanju servera: $e');
      return false;
    }
  }

  /// Obrađuje primljene podatke
  void _handleReceivedData(Uint8List data) {
    try {
      // Parsiraj primljene podatke u poruku
      final message = _parseMessage(data);
      if (message != null) {
        _messageController.add(message);
      }
    } catch (e) {
      print('Greška pri obradi primljenih podataka: $e');
    }
  }

  /// Parsira primljene podatke u poruku
  NetworkMessage? _parseMessage(Uint8List data) {
    try {
      // Format poruke: [type(1)][sourceId(36)][targetId(36)][payload(n)]
      if (data.length < 73) return null; // Minimalna veličina poruke

      final type = MessageType.values[data[0]];
      final sourceId = String.fromCharCodes(data.sublist(1, 37));
      final targetId = String.fromCharCodes(data.sublist(37, 73));
      final payload = data.sublist(73);

      return NetworkMessage(
        type: type,
        sourceId: sourceId,
        targetId: targetId,
        payload: payload,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      print('Greška pri parsiranju poruke: $e');
      return null;
    }
  }

  /// Serijalizuje poruku u bajtove
  Uint8List _serializeMessage(NetworkMessage message) {
    final buffer = BytesBuilder();

    // Dodaj tip poruke
    buffer.addByte(message.type.index);

    // Dodaj source ID (fiksirano na 36 bajtova)
    final sourceIdBytes = Uint8List(36)..setAll(0, message.sourceId.codeUnits);
    buffer.add(sourceIdBytes);

    // Dodaj target ID (fiksirano na 36 bajtova)
    final targetIdBytes = Uint8List(36)..setAll(0, message.targetId.codeUnits);
    buffer.add(targetIdBytes);

    // Dodaj payload
    buffer.add(message.payload);

    return buffer.toBytes();
  }

  @override
  Future<bool> send(NetworkMessage message) async {
    if (!_isConnected) {
      final connected = await _connectAsClient();
      if (!connected) return false;
    }

    try {
      final data = _serializeMessage(message);
      _socket!.add(data);
      await _socket!.flush();
      return true;
    } catch (e) {
      print('Greška pri slanju poruke: $e');
      return false;
    }
  }

  @override
  Future<void> close() async {
    _isConnected = false;
    await _socket?.close();
    await _server?.close();
    await _messageController.close();
  }
}
