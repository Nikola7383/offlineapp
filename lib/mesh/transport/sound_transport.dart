import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/node.dart';
import 'message_transport.dart';

/// Implementacija transporta preko zvuka
class SoundTransport implements MessageTransport {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final _stats = _SoundTransportStats();

  // Stream controller za poruke
  final _messageController = StreamController<TransportMessage>.broadcast();

  // Status transporta
  TransportStatus _status = TransportStatus.notInitialized;

  // Konstante
  static const int SAMPLE_RATE = 44100;
  static const int CHANNELS = 1;
  static const Duration PACKET_DURATION = Duration(milliseconds: 100);

  @override
  TransportStatus get status => _status;

  @override
  Stream<TransportMessage> get messageStream => _messageController.stream;

  @override
  Future<void> initialize() async {
    try {
      _status = TransportStatus.initializing;

      // Proveri dozvole
      final micPermission = await Permission.microphone.request();
      final storagePermission = await Permission.storage.request();

      if (micPermission != PermissionStatus.granted ||
          storagePermission != PermissionStatus.granted) {
        throw TransportException('Potrebne su dozvole za mikrofon i storage');
      }

      // Inicijalizuj player i recorder
      await _player.openPlayer();
      await _recorder.openRecorder();

      // Započni osluškivanje
      await _startListening();

      _status = TransportStatus.ready;
    } catch (e) {
      _status = TransportStatus.error;
      throw TransportException(
        'Inicijalizacija zvučnog transporta nije uspela',
        details: e,
      );
    }
  }

  @override
  Future<void> sendData(
    String targetNodeId,
    Uint8List data,
    TransportOptions options,
  ) async {
    try {
      // Konvertuj podatke u audio signal
      final audioData = await _encodeData(data);

      // Reprodukuj zvuk
      await _player.startPlayer(
        fromDataBuffer: audioData,
        sampleRate: SAMPLE_RATE,
        numChannels: CHANNELS,
      );

      _stats._recordSentMessage(data.length);

      // Čekaj da se završi reprodukcija
      await _player.stopPlayer();

      // Čekaj potvrdu ako je potrebno
      if (options.requireAck) {
        await _waitForAck(options.timeout);
      }
    } catch (e) {
      _stats._recordFailedDelivery();
      throw TransportException(
        'Slanje podataka nije uspelo',
        details: e,
      );
    }
  }

  @override
  Future<void> broadcast(Uint8List data, TransportOptions options) async {
    // Za zvučni transport, broadcast je isto što i sendData
    await sendData('broadcast', data, options);
  }

  @override
  Future<List<Node>> discoverNodes() async {
    // Zvučni transport ne podržava otkrivanje čvorova
    // Vraća samo jedan virtuelni čvor koji predstavlja sve slušaoce
    return [
      Node(
        id: 'broadcast',
        isActive: true,
        batteryLevel: 1.0,
        type: NodeType.regular,
        capabilities: {
          'transport': 'sound',
          'sampleRate': SAMPLE_RATE,
          'channels': CHANNELS,
        },
      ),
    ];
  }

  @override
  Future<bool> isNodeAvailable(String nodeId) async {
    // Za zvučni transport, čvor je uvek "dostupan"
    return true;
  }

  @override
  Future<void> dispose() async {
    _status = TransportStatus.notInitialized;

    await _player.closePlayer();
    await _recorder.closeRecorder();
    await _messageController.close();
  }

  /// Započinje osluškivanje zvučnih signala
  Future<void> _startListening() async {
    await _recorder.startRecorder(
      codec: Codec.pcm16,
      numChannels: CHANNELS,
      sampleRate: SAMPLE_RATE,
    );

    _recorder.onProgress!.listen((e) {
      if (e.decibels != null) {
        _stats._recordSignalStrength(e.decibels! / 100);
      }
    });

    _recorder.setSubscriptionDuration(PACKET_DURATION);
  }

  /// Obrađuje primljene audio podatke
  Future<void> _processAudioData(Uint8List buffer) async {
    try {
      // Dekodiraj podatke iz audio signala
      final data = await _decodeData(buffer);
      if (data == null) return; // Nije validna poruka

      _stats._recordReceivedMessage(data.length);

      _messageController.add(TransportMessage(
        sourceNodeId: 'broadcast',
        data: data,
        timestamp: DateTime.now(),
        signalStrength: await _calculateSignalStrength(buffer),
        metadata: {
          'transport': 'sound',
          'sampleRate': SAMPLE_RATE,
          'channels': CHANNELS,
        },
      ));
    } catch (e) {
      print('Greška pri obradi audio podataka: $e');
    }
  }

  /// Enkodira podatke u audio signal
  Future<Uint8List> _encodeData(Uint8List data) async {
    // TODO: Implementirati naprednije enkodiranje
    // Za sada samo kopira podatke
    return Uint8List.fromList(data);
  }

  /// Dekodira podatke iz audio signala
  Future<Uint8List?> _decodeData(Uint8List buffer) async {
    // TODO: Implementirati naprednije dekodiranje
    // Za sada samo kopira podatke ako su validni
    if (buffer.length < 10) return null; // Minimalna veličina poruke
    return Uint8List.fromList(buffer);
  }

  /// Računa jačinu signala iz audio buffera
  Future<double> _calculateSignalStrength(Uint8List buffer) async {
    // TODO: Implementirati pravi proračun jačine signala
    // Za sada vraća fiksnu vrednost
    return 0.8;
  }

  /// Čeka potvrdu prijema
  Future<void> _waitForAck(Duration timeout) async {
    // TODO: Implementirati protokol za potvrdu prijema
    await Future.delayed(const Duration(milliseconds: 100));
  }
}

/// Implementacija statistike za zvučni transport
class _SoundTransportStats implements TransportStats {
  int _messagesSent = 0;
  int _messagesReceived = 0;
  int _failedDeliveries = 0;
  double _totalLatency = 0;
  int _latencyMeasurements = 0;
  double _totalSignalStrength = 0;
  int _signalMeasurements = 0;

  @override
  int get totalMessagesSent => _messagesSent;

  @override
  int get totalMessagesReceived => _messagesReceived;

  @override
  int get failedDeliveries => _failedDeliveries;

  @override
  double get averageLatency =>
      _latencyMeasurements > 0 ? _totalLatency / _latencyMeasurements : 0;

  @override
  double get averageSignalStrength =>
      _signalMeasurements > 0 ? _totalSignalStrength / _signalMeasurements : 0;

  @override
  double get deliverySuccessRate => _messagesSent > 0
      ? (_messagesSent - _failedDeliveries) / _messagesSent
      : 0.0;

  @override
  void reset() {
    _messagesSent = 0;
    _messagesReceived = 0;
    _failedDeliveries = 0;
    _totalLatency = 0;
    _latencyMeasurements = 0;
    _totalSignalStrength = 0;
    _signalMeasurements = 0;
  }

  void _recordSentMessage(int size) {
    _messagesSent++;
  }

  void _recordReceivedMessage(int size) {
    _messagesReceived++;
  }

  void _recordFailedDelivery() {
    _failedDeliveries++;
  }

  void _recordLatency(Duration latency) {
    _totalLatency += latency.inMilliseconds;
    _latencyMeasurements++;
  }

  void _recordSignalStrength(double strength) {
    _totalSignalStrength += strength;
    _signalMeasurements++;
  }
}
