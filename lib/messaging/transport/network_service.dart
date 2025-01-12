import 'package:injectable/injectable.dart';
import '../../core/interfaces/base_service.dart';
import '../../core/interfaces/network_service_interface.dart';
import '../../core/models/encrypted_message.dart';
import 'dart:async';

/// Servis za mrežnu komunikaciju
@LazySingleton(as: INetworkService)
class NetworkService implements INetworkService {
  final _messageController = StreamController<EncryptedMessage>.broadcast();
  bool _isConnected = false;

  @override
  Future<void> initialize() async {
    _isConnected = true;
  }

  @override
  Future<void> dispose() async {
    await _messageController.close();
    _isConnected = false;
  }

  @override
  Stream<EncryptedMessage> get messageStream => _messageController.stream;

  @override
  bool get isConnected => _isConnected;

  @override
  Future<void> sendMessage(EncryptedMessage message) async {
    if (!_isConnected) {
      throw Exception('Nije uspostavljena konekcija');
    }

    try {
      // TODO: Implementirati slanje poruke preko mreže
      // Za sada samo emitujemo poruku na stream
      _messageController.add(message);
    } catch (e) {
      throw Exception('Greška prilikom slanja poruke: $e');
    }
  }

  @override
  Future<void> disconnect() async {
    _isConnected = false;
  }

  @override
  Future<void> connect() async {
    _isConnected = true;
  }
}
