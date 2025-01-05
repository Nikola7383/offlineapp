import 'dart:async';
import '../interfaces/mesh_service.dart';
import '../interfaces/logger_service.dart';
import '../models/message.dart';
import '../models/result.dart';
import '../models/service_error.dart';
import 'base_service.dart';

class MeshService extends BaseService implements IMeshService {
  final _messageController = StreamController<Message>.broadcast();
  final _connectionStatus = StreamController<bool>.broadcast();
  bool _isConnected = false;
  Timer? _heartbeatTimer;

  MeshService(ILoggerService logger) : super(logger);

  @override
  String get serviceName => 'MeshService';

  @override
  bool get isConnected => _isConnected;

  @override
  Stream<Message> get messageStream => _messageController.stream;

  @override
  Future<Result<void>> sendMessage(Message message) async {
    return wrapOperation('sendMessage', () async {
      if (!_isConnected) {
        return Result.failure('Not connected to mesh network');
      }

      // Simuliramo slanje poruke
      await Future.delayed(const Duration(milliseconds: 100));

      // Emitujemo status update
      _messageController.add(message.copyWith(status: MessageStatus.sending));

      // Simuliramo uspešno slanje
      await Future.delayed(const Duration(milliseconds: 200));
      _messageController.add(message.copyWith(status: MessageStatus.sent));

      return Result.success();
    }).then((value) => value).catchError((error, stackTrace) {
      return Result.failure(error.toString(), stackTrace);
    });
  }

  @override
  Future<Result<void>> sendBatch(List<Message> messages) async {
    return wrapOperation('sendBatch', () async {
      if (!_isConnected) {
        return Result.failure('Not connected to mesh network');
      }

      for (final message in messages) {
        final result = await sendMessage(message);
        if (!result.isSuccess) {
          return result;
        }
      }

      return Result.success();
    }).then((value) => value).catchError((error, stackTrace) {
      return Result.failure(error.toString(), stackTrace);
    });
  }

  @override
  Future<void> onInitialize() async {
    // Simuliramo povezivanje na mrežu
    await Future.delayed(const Duration(seconds: 1));
    _isConnected = true;

    // Pokrećemo heartbeat timer
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkConnection(),
    );
  }

  @override
  Future<void> onDispose() async {
    _heartbeatTimer?.cancel();
    _isConnected = false;
    await _messageController.close();
    await _connectionStatus.close();
  }

  Future<void> _checkConnection() async {
    try {
      // Simuliramo proveru konekcije
      await Future.delayed(const Duration(milliseconds: 100));
      if (_isConnected != true) {
        _isConnected = true;
        _connectionStatus.add(true);
      }
    } catch (e) {
      _isConnected = false;
      _connectionStatus.add(false);
    }
  }
}
