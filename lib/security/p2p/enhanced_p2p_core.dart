import 'dart:async';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:wifi_direct/wifi_direct.dart';
import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';

class EnhancedP2PCore {
  static final EnhancedP2PCore _instance = EnhancedP2PCore._internal();
  final Map<String, P2PConnection> _activeConnections = {};
  final List<P2PProtocol> _availableProtocols = [];
  final LocalEncryption _encryption = LocalEncryption();

  factory EnhancedP2PCore() {
    return _instance;
  }

  EnhancedP2PCore._internal() {
    _initializeP2P();
  }

  Future<void> _initializeP2P() async {
    // Inicijalizacija svih P2P protokola
    _availableProtocols.addAll([
      BluetoothLEProtocol(),
      WifiDirectProtocol(),
      NearbyConnectionsProtocol()
    ]);

    // Postavljanje fallback mehanizama
    await _setupFallbackMechanisms();

    // Inicijalizacija optimizovane enkripcije
    await _initializeOptimizedEncryption();
  }

  Future<P2PConnection> establishConnection(
      String peerId, P2PConnectionConfig config) async {
    // Pokušaj konekcije kroz sve dostupne protokole
    for (var protocol in _getOptimalProtocolOrder()) {
      try {
        final connection = await _tryConnect(protocol, peerId, config);
        if (connection != null) {
          _activeConnections[connection.id] = connection;
          return connection;
        }
      } catch (e) {
        await _handleConnectionError(e, protocol, peerId);
        continue;
      }
    }

    throw P2PException('Unable to establish connection through any protocol');
  }

  Future<void> sendData(
      String connectionId, Uint8List data, TransferPriority priority) async {
    final connection = _activeConnections[connectionId];
    if (connection == null) throw P2PException('Invalid connection');

    // Optimizovana enkripcija za brži transfer
    final encryptedData = await _optimizedEncryption(data, priority);

    // Chunk-based transfer sa auto-resume
    final chunks = _prepareDataChunks(encryptedData);

    for (var chunk in chunks) {
      try {
        await _sendChunkWithRetry(connection, chunk);
      } catch (e) {
        // Automatski fallback na drugi protokol ako trenutni fails
        await _handleTransferError(e, connection, chunk);
      }
    }
  }

  Future<Uint8List> _optimizedEncryption(
      Uint8List data, TransferPriority priority) async {
    switch (priority) {
      case TransferPriority.high:
        return await _encryption.fastEncrypt(data);
      case TransferPriority.balanced:
        return await _encryption.balancedEncrypt(data);
      case TransferPriority.secure:
        return await _encryption.secureEncrypt(data);
    }
  }

  List<P2PProtocol> _getOptimalProtocolOrder() {
    // Dinamičko određivanje najboljeg protokola based on:
    // - Trenutna dostupnost
    // - Istorija performansi
    // - Battery status
    // - Signal strength
    return _availableProtocols
      ..sort((a, b) => _calculateProtocolScore(b) - _calculateProtocolScore(a));
  }

  int _calculateProtocolScore(P2PProtocol protocol) {
    int score = 0;

    // Performance score
    score += protocol.getAverageSpeed() * 2;

    // Reliability score
    score += protocol.getReliabilityRating() * 3;

    // Battery efficiency
    score += protocol.getBatteryEfficiency();

    // Current availability
    score += protocol.isCurrentlyAvailable() ? 5 : 0;

    return score;
  }

  Future<void> _handleTransferError(
      dynamic error, P2PConnection connection, DataChunk chunk) async {
    // Pokušaj prebacivanja na alternativni protokol
    final alternativeProtocol =
        _findBestAlternativeProtocol(connection.protocol);

    if (alternativeProtocol != null) {
      final newConnection = await _tryConnect(
          alternativeProtocol, connection.peerId, connection.config);

      if (newConnection != null) {
        _activeConnections[connection.id] = newConnection;
        await _sendChunkWithRetry(newConnection, chunk);
      }
    }
  }
}

class P2PConnection {
  final String id;
  final String peerId;
  final P2PProtocol protocol;
  final P2PConnectionConfig config;
  final DateTime established;

  P2PConnection(
      {required this.id,
      required this.peerId,
      required this.protocol,
      required this.config,
      required this.established});
}

enum TransferPriority {
  high, // Brži transfer, balansirano šifrovanje
  balanced, // Balans brzine i sigurnosti
  secure // Maksimalna sigurnost
}

class P2PConnectionConfig {
  final bool autoReconnect;
  final Duration timeout;
  final TransferPriority defaultPriority;
  final bool enableFallback;
  final int maxRetries;

  P2PConnectionConfig(
      {this.autoReconnect = true,
      this.timeout = const Duration(seconds: 30),
      this.defaultPriority = TransferPriority.balanced,
      this.enableFallback = true,
      this.maxRetries = 3});
}

class DataChunk {
  final int sequenceNumber;
  final Uint8List data;
  final String checksum;

  DataChunk(
      {required this.sequenceNumber,
      required this.data,
      required this.checksum});
}
