import 'package:injectable/injectable.dart';
import '../interfaces/message_service_interface.dart';
import '../interfaces/async_service.dart';
import '../../messaging/transport/message_service.dart';
import '../models/message.dart';
import '../models/message_types.dart';
import '../mesh/mesh_network.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

/// Servis za hitne poruke
@LazySingleton()
class EmergencyMessageSystem implements IAsyncService {
  final IMessageService _messageService;
  final MeshNetwork _meshNetwork;
  final SharedPreferences _prefs;
  final _emergencyController = StreamController<Message>.broadcast();
  bool _isActive = false;

  static const String _emergencyModeKey = 'emergency_mode';
  static const String _emergencyChannelKey = 'emergency_channel';
  static const Duration _retryInterval = Duration(seconds: 30);
  static const int _maxRetries = 5;

  EmergencyMessageSystem(
    this._messageService,
    this._meshNetwork,
    this._prefs,
  );

  @override
  Future<void> initialize() async {
    _isActive = _prefs.getBool(_emergencyModeKey) ?? false;
    if (_isActive) {
      await reconnect();
    }
  }

  @override
  Future<void> dispose() async {
    _isActive = false;
    await _emergencyController.close();
  }

  @override
  Future<void> reconnect() async {
    if (!_isActive) return;

    try {
      await _meshNetwork.reconnect();
      _subscribeToEmergencyMessages();
    } catch (e) {
      throw Exception('Greška prilikom povezivanja na mrežu: $e');
    }
  }

  @override
  Future<void> pause() async {
    _isActive = false;
    await _prefs.setBool(_emergencyModeKey, false);
  }

  @override
  Future<void> resume() async {
    _isActive = true;
    await _prefs.setBool(_emergencyModeKey, true);
    await reconnect();
  }

  /// Šalje hitnu poruku
  Future<void> sendEmergencyMessage(String content) async {
    if (!_isActive) {
      throw Exception('Emergency sistem nije aktivan');
    }

    final message = _messageService.createMessage(
      recipientId: 'broadcast',
      content: content,
      type: MessageType.urgent.value,
      priority: 1,
      metadata: {
        'emergency': true,
        'channel': emergencyChannel,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    var retries = 0;
    while (retries < _maxRetries) {
      try {
        await _messageService.sendMessage(message);
        break;
      } catch (e) {
        retries++;
        if (retries >= _maxRetries) {
          throw Exception(
              'Nije uspelo slanje hitne poruke nakon $_maxRetries pokušaja');
        }
        await Future.delayed(_retryInterval);
      }
    }
  }

  /// Stream hitnih poruka
  Stream<Message> get emergencyMessageStream => _emergencyController.stream;

  /// Da li je emergency mode aktivan
  bool get isActive => _isActive;

  /// Kanal za hitne poruke
  String get emergencyChannel =>
      _prefs.getString(_emergencyChannelKey) ?? 'emergency';

  /// Postavlja kanal za hitne poruke
  Future<void> setEmergencyChannel(String channel) async {
    await _prefs.setString(_emergencyChannelKey, channel);
  }

  /// Pretplaćuje se na hitne poruke
  void _subscribeToEmergencyMessages() {
    _meshNetwork.messageStream.listen((encryptedMessage) async {
      try {
        final message = await _messageService.receiveMessage(encryptedMessage);
        if (_isEmergencyMessage(message)) {
          _emergencyController.add(message);
        }
      } catch (e) {
        print('Greška prilikom obrade hitne poruke: $e');
      }
    });
  }

  /// Proverava da li je poruka hitna
  bool _isEmergencyMessage(Message message) {
    return message.type == MessageType.urgent.value &&
        message.priority == 1 &&
        message.metadata['emergency'] == true &&
        message.metadata['channel'] == emergencyChannel;
  }
}
