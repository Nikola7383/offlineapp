import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../interfaces/connection_service.dart';
import '../interfaces/logger_service.dart';
import '../models/connection_models.dart';
import '../models/result.dart';
import 'base_service.dart';

class ConnectionService extends BaseService implements IConnectionService {
  final ConnectionConfig _config;
  final _statusController = StreamController<ConnectionStatus>.broadcast();
  final Connectivity _connectivity = Connectivity();
  final FlutterBluePlus _bluetooth = FlutterBluePlus.instance;

  Timer? _checkTimer;
  ConnectionStatus _currentStatus = ConnectionStatus.offline();
  int _reconnectAttempts = 0;

  ConnectionService(
    ILoggerService logger,
    this._config,
  ) : super(logger);

  @override
  String get serviceName => 'ConnectionService';

  @override
  Stream<ConnectionStatus> get statusStream => _statusController.stream;

  @override
  ConnectionStatus get currentStatus => _currentStatus;

  @override
  Set<ConnectionType> get availableTypes => _config.enabledTypes;

  @override
  Future<void> onInitialize() async {
    // Počinjemo sa praćenjem konekcije
    _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);

    if (_config.enabledTypes.contains(ConnectionType.bluetooth)) {
      _bluetooth.state.listen(_handleBluetoothState);
    }

    // Inicijalna provera
    await checkConnection();

    // Periodična provera
    _checkTimer = Timer.periodic(
      _config.checkInterval,
      (_) => checkConnection(),
    );
  }

  @override
  Future<void> onDispose() async {
    _checkTimer?.cancel();
    await _statusController.close();
  }

  @override
  Future<bool> isAvailable(ConnectionType type) async {
    return wrapOperation('isAvailable', () async {
      switch (type) {
        case ConnectionType.wifi:
          final result = await _connectivity.checkConnectivity();
          return result == ConnectivityResult.wifi;

        case ConnectionType.bluetooth:
          if (!_config.enabledTypes.contains(ConnectionType.bluetooth)) {
            return false;
          }
          return _bluetooth.isOn;

        case ConnectionType.cellular:
          final result = await _connectivity.checkConnectivity();
          return result == ConnectivityResult.mobile;

        case ConnectionType.ethernet:
          final result = await _connectivity.checkConnectivity();
          return result == ConnectivityResult.ethernet;
      }
    });
  }

  @override
  Future<Result<void>> enable(ConnectionType type) async {
    return wrapOperation('enable', () async {
      if (!_config.enabledTypes.contains(type)) {
        return Result.failure('Connection type $type is not enabled in config');
      }

      switch (type) {
        case ConnectionType.bluetooth:
          if (!await _bluetooth.isOn) {
            // Na većini platformi ne možemo programski uključiti Bluetooth
            return Result.failure('Cannot enable Bluetooth programmatically');
          }
          break;
        default:
          // Ostale tipove konekcija ne možemo direktno enable-ovati
          return Result.failure('Cannot enable $type programmatically');
      }

      await checkConnection();
      return Result.success();
    });
  }

  @override
  Future<Result<void>> disable(ConnectionType type) async {
    return wrapOperation('disable', () async {
      switch (type) {
        case ConnectionType.bluetooth:
          if (await _bluetooth.isOn) {
            // Na većini platformi ne možemo programski isključiti Bluetooth
            return Result.failure('Cannot disable Bluetooth programmatically');
          }
          break;
        default:
          return Result.failure('Cannot disable $type programmatically');
      }

      await checkConnection();
      return Result.success();
    });
  }

  @override
  Future<Result<ConnectionStatus>> checkConnection() async {
    return wrapOperation('checkConnection', () async {
      final activeTypes = <ConnectionType>{};
      var strength = ConnectionStrength.none;

      // Proveravamo WiFi/Cellular
      final connectivityResult = await _connectivity.checkConnectivity();
      switch (connectivityResult) {
        case ConnectivityResult.wifi:
          activeTypes.add(ConnectionType.wifi);
          strength = ConnectionStrength.strong;
          break;
        case ConnectivityResult.mobile:
          activeTypes.add(ConnectionType.cellular);
          strength = ConnectionStrength.moderate;
          break;
        case ConnectivityResult.ethernet:
          activeTypes.add(ConnectionType.ethernet);
          strength = ConnectionStrength.strong;
          break;
        default:
          break;
      }

      // Proveravamo Bluetooth ako je omogućen
      if (_config.enabledTypes.contains(ConnectionType.bluetooth) &&
          await _bluetooth.isOn) {
        activeTypes.add(ConnectionType.bluetooth);
        // Ažuriramo strength samo ako je trenutni slabiji
        if (strength.index < ConnectionStrength.moderate.index) {
          strength = ConnectionStrength.moderate;
        }
      }

      _currentStatus = ConnectionStatus(
        isConnected: activeTypes.isNotEmpty,
        activeTypes: activeTypes,
        strength: strength,
        timestamp: DateTime.now(),
      );

      _statusController.add(_currentStatus);
      return Result.success(_currentStatus);
    });
  }

  Future<void> _handleConnectivityChange(ConnectivityResult result) async {
    await checkConnection();

    if (!_currentStatus.isConnected && _config.autoReconnect) {
      _attemptReconnect();
    } else {
      _reconnectAttempts = 0;
    }
  }

  void _handleBluetoothState(BluetoothState state) {
    checkConnection();
  }

  Future<void> _attemptReconnect() async {
    if (_reconnectAttempts >= _config.maxReconnectAttempts) {
      await _logger.warning(
        'Max reconnection attempts reached',
        {'attempts': _reconnectAttempts},
      );
      return;
    }

    _reconnectAttempts++;
    await _logger.info(
      'Attempting to reconnect',
      {'attempt': _reconnectAttempts},
    );

    await Future.delayed(Duration(seconds: _reconnectAttempts * 2));
    await checkConnection();
  }
}
