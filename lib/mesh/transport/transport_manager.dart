import 'dart:async';
import 'dart:typed_data';
import '../models/node.dart';
import 'message_transport.dart';
import 'bluetooth_transport.dart';
import 'wifi_direct_transport.dart';
import 'sound_transport.dart';
import 'transport_selector.dart';
import 'transport_stats_collector.dart';

/// Upravlja svim transportnim slojevima i rutira poruke
class TransportManager {
  final BluetoothTransport _bluetoothTransport;
  final WiFiDirectTransport _wifiDirectTransport;
  final SoundTransport _soundTransport;
  final TransportSelector _selector = TransportSelector();

  // Stream controller za sve poruke
  final _messageController = StreamController<TransportMessage>.broadcast();

  // Aktivni transporti
  final Map<String, MessageTransport> _activeTransports = {};

  // Status transporta po čvoru
  final Map<String, Map<String, TransportStatus>> _nodeTransportStatus = {};

  // Statistika po transportu
  final Map<String, TransportStatsCollector> _transportStats = {};

  // Konstante
  static const Duration CONNECTION_TIMEOUT = Duration(seconds: 30);
  static const int MAX_RETRIES = 3;
  static const Duration RETRY_DELAY = Duration(seconds: 1);

  TransportManager({
    BluetoothTransport? bluetoothTransport,
    WiFiDirectTransport? wifiDirectTransport,
    SoundTransport? soundTransport,
  })  : _bluetoothTransport = bluetoothTransport ?? BluetoothTransport(),
        _wifiDirectTransport = wifiDirectTransport ?? WiFiDirectTransport(),
        _soundTransport = soundTransport ?? SoundTransport();

  /// Inicijalizuje sve transportne slojeve
  Future<void> initialize() async {
    try {
      // Inicijalizuj sve transporte
      await Future.wait([
        _initTransport(_bluetoothTransport, 'bluetooth'),
        _initTransport(_wifiDirectTransport, 'wifi_direct'),
        _initTransport(_soundTransport, 'sound'),
      ]);

      // Osluškuj poruke sa svih transporta
      _setupMessageListeners();
    } catch (e) {
      throw Exception('Inicijalizacija transporta nije uspela: $e');
    }
  }

  /// Šalje podatke određenom čvoru preko optimalnog transporta
  Future<void> sendData(
    String targetNodeId,
    Uint8List data, {
    TransportPriority priority = TransportPriority.normal,
    bool requireAck = true,
    Duration? timeout,
    Map<String, dynamic>? metadata,
  }) async {
    final transport = await _selectBestTransport(
      targetNodeId,
      priority: priority,
    );
    if (transport == null) {
      throw Exception('Nije pronađen dostupan transport za čvor $targetNodeId');
    }

    final options = TransportOptions(
      priority: priority,
      requireAck: requireAck,
      timeout: timeout ?? CONNECTION_TIMEOUT,
      metadata: metadata,
    );

    final startTime = DateTime.now();
    var attempts = 0;

    while (attempts < MAX_RETRIES) {
      try {
        await transport.sendData(targetNodeId, data, options);

        // Beleži uspešno slanje
        final transportId = _getTransportId(transport);
        if (transportId != null) {
          final stats = _transportStats[transportId]!;
          final latency =
              DateTime.now().difference(startTime).inMilliseconds.toDouble();
          stats.recordMessageSent(data.length, latency: latency);
        }

        return;
      } catch (e) {
        attempts++;
        final transportId = _getTransportId(transport);
        if (transportId != null) {
          _transportStats[transportId]!.recordFailedDelivery();
        }

        if (attempts >= MAX_RETRIES) {
          throw Exception('Slanje nije uspelo nakon $MAX_RETRIES pokušaja: $e');
        }
        await Future.delayed(RETRY_DELAY);
      }
    }
  }

  /// Šalje broadcast poruku preko svih dostupnih transporta
  Future<void> broadcast(
    Uint8List data, {
    TransportPriority priority = TransportPriority.normal,
    bool requireAck = false,
    Duration? timeout,
    Map<String, dynamic>? metadata,
  }) async {
    final options = TransportOptions(
      priority: priority,
      requireAck: requireAck,
      timeout: timeout ?? CONNECTION_TIMEOUT,
      metadata: metadata,
    );

    final futures = <Future>[];

    for (final transport in _activeTransports.values) {
      futures.add(
        transport.broadcast(data, options).catchError((e) {
          print('Broadcast greška na ${transport.runtimeType}: $e');
        }),
      );
    }

    await Future.wait(futures);
  }

  /// Stream svih primljenih poruka
  Stream<TransportMessage> get messageStream => _messageController.stream;

  /// Vraća listu svih dostupnih čvorova
  Future<List<Node>> discoverNodes() async {
    final nodes = <String, Node>{};

    for (final transport in _activeTransports.values) {
      try {
        final discoveredNodes = await transport.discoverNodes();
        for (final node in discoveredNodes) {
          nodes[node.id] = node;
        }
      } catch (e) {
        print('Greška pri otkrivanju čvorova na ${transport.runtimeType}: $e');
      }
    }

    return nodes.values.toList();
  }

  /// Čisti resurse
  Future<void> dispose() async {
    await Future.wait([
      _bluetoothTransport.dispose(),
      _wifiDirectTransport.dispose(),
      _soundTransport.dispose(),
    ]);

    await _messageController.close();
    _activeTransports.clear();
    _nodeTransportStatus.clear();
  }

  /// Inicijalizuje pojedinačni transport
  Future<void> _initTransport(
    MessageTransport transport,
    String transportId,
  ) async {
    try {
      await transport.initialize();
      _activeTransports[transportId] = transport;
      _transportStats[transportId] = TransportStatsCollector();
    } catch (e) {
      print('Inicijalizacija $transportId transporta nije uspela: $e');
    }
  }

  /// Postavlja osluškivače za poruke sa svih transporta
  void _setupMessageListeners() {
    for (final entry in _activeTransports.entries) {
      final transportId = entry.key;
      final transport = entry.value;

      transport.messageStream.listen(
        (message) {
          _messageController.add(message);

          // Beleži primljenu poruku
          final stats = _transportStats[transportId]!;
          stats.recordMessageReceived(
            message.data.length,
            signalStrength: message.signalStrength,
          );
        },
        onError: (error) {
          print('Greška pri primanju poruke: $error');
        },
      );
    }
  }

  /// Vraća ID transporta
  String? _getTransportId(MessageTransport transport) {
    try {
      return _activeTransports.entries
          .firstWhere((e) => e.value == transport)
          .key;
    } catch (e) {
      return null;
    }
  }

  /// Bira najbolji transport za slanje poruke određenom čvoru
  Future<MessageTransport?> _selectBestTransport(
    String targetNodeId, {
    TransportPriority priority = TransportPriority.normal,
  }) async {
    var bestTransport = _findCachedTransport(targetNodeId);
    if (bestTransport != null) {
      return bestTransport;
    }

    // Proveri dostupnost na svim transportima
    final availableTransports = <MessageTransport>[];

    for (final transport in _activeTransports.values) {
      try {
        final isAvailable = await transport.isNodeAvailable(targetNodeId);
        if (isAvailable) {
          availableTransports.add(transport);

          // Ažuriraj statistiku ako ne postoji
          final transportId = transport.runtimeType.toString();
          if (!_transportStats.containsKey(transportId)) {
            _transportStats[transportId] = TransportStatsCollector();
          }
        }
      } catch (e) {
        print('Greška pri proveri dostupnosti na ${transport.runtimeType}: $e');
      }
    }

    if (availableTransports.isEmpty) {
      return null;
    }

    // Izaberi najbolji transport
    bestTransport = _selector.selectBestTransport(
      availableTransports,
      priority,
      _transportStats,
    );

    if (bestTransport != null) {
      _cacheTransportStatus(targetNodeId, bestTransport);
    }

    return bestTransport;
  }

  /// Vraća keširani transport za čvor ako postoji
  MessageTransport? _findCachedTransport(String nodeId) {
    final status = _nodeTransportStatus[nodeId];
    if (status == null) return null;

    for (final entry in status.entries) {
      if (entry.value == TransportStatus.ready) {
        return _activeTransports[entry.key];
      }
    }

    return null;
  }

  /// Kešira status transporta za čvor
  void _cacheTransportStatus(String nodeId, MessageTransport transport) {
    final transportId =
        _activeTransports.entries.firstWhere((e) => e.value == transport).key;

    _nodeTransportStatus[nodeId] ??= {};
    _nodeTransportStatus[nodeId]![transportId] = transport.status;
  }

  /// Vraća statistiku za transport
  Future<TransportStats> _getTransportStats(MessageTransport transport) async {
    final transportId = _getTransportId(transport);
    if (transportId == null) {
      throw Exception('Transport nije pronađen');
    }
    return _transportStats[transportId]!;
  }
}
