import 'dart:async';
import 'package:flutter/foundation.dart';
import 'network_communicator.dart';
import 'connection_factory.dart';

/// Tip konekcije
enum ConnectionType {
  bluetooth,
  wifiDirect,
  sound,
}

/// Status konekcije
enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

/// Informacije o konekciji
class ConnectionInfo {
  final String nodeId;
  final ConnectionType type;
  final ConnectionStatus status;
  final DateTime lastActivity;
  final int retryCount;
  final String? errorMessage;

  const ConnectionInfo({
    required this.nodeId,
    required this.type,
    required this.status,
    required this.lastActivity,
    this.retryCount = 0,
    this.errorMessage,
  });

  ConnectionInfo copyWith({
    ConnectionType? type,
    ConnectionStatus? status,
    DateTime? lastActivity,
    int? retryCount,
    String? errorMessage,
  }) {
    return ConnectionInfo(
      nodeId: nodeId,
      type: type ?? this.type,
      status: status ?? this.status,
      lastActivity: lastActivity ?? this.lastActivity,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Upravlja konekcijama sa čvorovima
class ConnectionManager {
  // Aktivne konekcije
  final Map<String, NodeConnection> _connections = {};

  // Informacije o konekcijama
  final Map<String, ConnectionInfo> _connectionInfo = {};

  // Stream controller za promene statusa
  final _statusController = StreamController<ConnectionInfo>.broadcast();

  // Konstante
  static const Duration RETRY_INTERVAL = Duration(seconds: 5);
  static const int MAX_RETRIES = 3;

  Stream<ConnectionInfo> get statusStream => _statusController.stream;

  /// Vraća informacije o konekciji za čvor
  ConnectionInfo? getConnectionInfo(String nodeId) {
    return _connectionInfo[nodeId];
  }

  /// Vraća sve aktivne konekcije
  List<ConnectionInfo> getActiveConnections() {
    return _connectionInfo.values
        .where((info) => info.status == ConnectionStatus.connected)
        .toList();
  }

  /// Uspostavlja konekciju sa čvorom
  Future<bool> connect(String nodeId, {ConnectionType? preferredType}) async {
    // Proveri da li je već povezan
    if (_connections.containsKey(nodeId)) {
      return true;
    }

    // Ažuriraj status
    _updateConnectionInfo(
      nodeId,
      ConnectionStatus.connecting,
      preferredType ??
          await ConnectionFactory.getBestAvailableType() ??
          ConnectionType.bluetooth,
    );

    try {
      // Pokušaj uspostaviti konekciju
      final connection = preferredType != null
          ? await ConnectionFactory.createConnection(nodeId, preferredType)
          : await ConnectionFactory.createBestConnection(nodeId);

      if (connection == null) {
        _updateConnectionInfo(
          nodeId,
          ConnectionStatus.error,
          preferredType ?? ConnectionType.bluetooth,
          'Nije moguće uspostaviti konekciju',
        );
        return false;
      }

      _connections[nodeId] = connection;

      // Ažuriraj status
      _updateConnectionInfo(
        nodeId,
        ConnectionStatus.connected,
        preferredType ??
            await ConnectionFactory.getBestAvailableType() ??
            ConnectionType.bluetooth,
      );

      // Pokreni monitoring konekcije
      _monitorConnection(nodeId);

      return true;
    } catch (e) {
      _updateConnectionInfo(
        nodeId,
        ConnectionStatus.error,
        preferredType ?? ConnectionType.bluetooth,
        'Greška pri povezivanju: $e',
      );
      return false;
    }
  }

  /// Prekida konekciju sa čvorom
  Future<void> disconnect(String nodeId) async {
    final connection = _connections.remove(nodeId);
    if (connection != null) {
      await connection.close();

      // Ažuriraj status
      _updateConnectionInfo(
        nodeId,
        ConnectionStatus.disconnected,
        _connectionInfo[nodeId]?.type ?? ConnectionType.bluetooth,
      );
    }
  }

  /// Ažurira informacije o konekciji
  void _updateConnectionInfo(
    String nodeId,
    ConnectionStatus status,
    ConnectionType type, [
    String? errorMessage,
  ]) {
    final existing = _connectionInfo[nodeId];
    final info = ConnectionInfo(
      nodeId: nodeId,
      type: type,
      status: status,
      lastActivity: DateTime.now(),
      retryCount: existing?.retryCount ?? 0,
      errorMessage: errorMessage,
    );

    _connectionInfo[nodeId] = info;
    _statusController.add(info);
  }

  /// Prati status konekcije
  void _monitorConnection(String nodeId) {
    Timer.periodic(RETRY_INTERVAL, (timer) async {
      final connection = _connections[nodeId];
      if (connection == null) {
        timer.cancel();
        return;
      }

      try {
        // Proveri status konekcije slanjem ping poruke
        final message = NetworkMessage(
          type: MessageType.ping,
          sourceId: 'local',
          targetId: nodeId,
          payload: Uint8List(0),
          timestamp: DateTime.now(),
        );

        final success = await connection.send(message);
        if (!success) {
          // Pokušaj ponovo uspostaviti konekciju
          final info = _connectionInfo[nodeId]!;
          if (info.retryCount >= MAX_RETRIES) {
            await disconnect(nodeId);
            timer.cancel();
          } else {
            _connectionInfo[nodeId] = info.copyWith(
              status: ConnectionStatus.connecting,
              retryCount: info.retryCount + 1,
            );

            final reconnected = await connect(nodeId, preferredType: info.type);
            if (!reconnected) {
              await disconnect(nodeId);
              timer.cancel();
            }
          }
        } else {
          // Ažuriraj vreme poslednje aktivnosti
          final info = _connectionInfo[nodeId]!;
          _connectionInfo[nodeId] = info.copyWith(
            lastActivity: DateTime.now(),
            retryCount: 0,
          );
        }
      } catch (e) {
        print('Greška pri praćenju konekcije sa čvorom $nodeId: $e');
      }
    });
  }

  /// Čisti resurse
  void dispose() {
    for (var connection in _connections.values) {
      connection.close();
    }
    _connections.clear();
    _connectionInfo.clear();
    _statusController.close();
  }

  /// Šalje ping paket čvoru
  Future<bool> sendPing(String nodeId) async {
    final connection = _connections[nodeId];
    if (connection == null) return false;

    try {
      final message = NetworkMessage(
        type: MessageType.ping,
        sourceId: 'local',
        targetId: nodeId,
        payload: Uint8List(0),
        timestamp: DateTime.now(),
      );

      return await connection.send(message);
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
    final connection = _connections[nodeId];
    if (connection == null) return false;

    try {
      final message = NetworkMessage(
        type: MessageType.data,
        sourceId: 'local',
        targetId: nodeId,
        payload: data,
        timestamp: DateTime.now(),
      );

      return await connection.send(message);
    } catch (e) {
      print('Greška pri slanju podataka čvoru $nodeId: $e');
      return false;
    }
  }
}
