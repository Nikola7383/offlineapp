import 'dart:async';
import 'dart:typed_data';
import '../models/protocol_manager.dart';
import '../models/node.dart';
import '../models/protocol.dart';
import '../models/sound_types.dart';

class SoundManager implements ProtocolManager {
  static const int FREQUENCY = 18000; // Hz - iznad ljudskog sluha
  static const int CHUNK_SIZE = 32; // bytes
  static const double MIN_AMPLITUDE = 0.1;

  final SoundInterface sound;
  final Map<String, DateTime> _lastHeardNodes = {};
  final StreamController<List<int>> _dataStreamController =
      StreamController.broadcast();
  bool _isListening = false;
  StreamSubscription? _audioSubscription;

  SoundManager([SoundInterface? soundInstance])
      : sound = soundInstance ?? Sound();

  @override
  Future<List<Node>> scanForDevices() async {
    List<Node> discoveredNodes = [];

    try {
      final permission = await sound.requestPermission();
      if (!permission) {
        throw Exception('Microphone permission denied');
      }

      await sound.startListening();

      // Slušaj 3 sekunde
      await for (SoundData data in sound.audioStream.timeout(
        Duration(seconds: 3),
        onTimeout: (sink) => sink.close(),
      )) {
        if (data.amplitude > MIN_AMPLITUDE) {
          final nodeId = _decodeNodeId(data.frequencies);
          if (nodeId != null && !_lastHeardNodes.containsKey(nodeId)) {
            _lastHeardNodes[nodeId] = DateTime.now();
            discoveredNodes.add(Node(
              nodeId,
              batteryLevel: 1.0,
              signalStrength: _calculateSignalStrength(data.amplitude),
              managers: <Protocol, ProtocolManager>{},
            ));
          }
        }
      }

      await sound.stopListening();
    } catch (e) {
      print('Sound scan error: $e');
    }

    return discoveredNodes;
  }

  @override
  Future<bool> sendData(String nodeId, List<int> data) async {
    try {
      final chunks = _splitIntoChunks(data, CHUNK_SIZE);

      for (var chunk in chunks) {
        final frequencies = _encodeData(chunk);
        await sound.playFrequencies(frequencies, FREQUENCY);
        // Kratka pauza između chunks
        await Future.delayed(Duration(milliseconds: 100));
      }

      return true;
    } catch (e) {
      print('Sound send error: $e');
      return false;
    }
  }

  @override
  Future<void> startListening() async {
    if (_isListening) return;

    try {
      final permission = await sound.requestPermission();
      if (!permission) {
        throw Exception('Microphone permission denied');
      }

      await sound.startListening();
      _isListening = true;

      _audioSubscription = sound.audioStream.listen((data) {
        if (data.amplitude > MIN_AMPLITUDE) {
          final decodedData = _decodeData(data.frequencies);
          if (decodedData != null) {
            _dataStreamController.add(decodedData);
          }
        }
      });
    } catch (e) {
      print('Start listening error: $e');
    }
  }

  @override
  Future<void> stopListening() async {
    _isListening = false;
    await _audioSubscription?.cancel();
    _audioSubscription = null;
    await sound.stopListening();
  }

  // Helper metode za enkodiranje/dekodiranje
  List<double> _encodeData(List<int> data) {
    // Pretvara bytes u frekvencije koristeći FSK (Frequency Shift Keying)
    List<double> frequencies = [];
    for (var byte in data) {
      for (var i = 0; i < 8; i++) {
        final bit = (byte >> i) & 1;
        frequencies.add(FREQUENCY + (bit * 100)); // 100Hz razlika za 0/1
      }
    }
    return frequencies;
  }

  List<int>? _decodeData(List<double> frequencies) {
    if (frequencies.isEmpty) return null;

    List<int> data = [];
    int currentByte = 0;
    int bitCount = 0;

    for (var freq in frequencies) {
      final bit = (freq > FREQUENCY + 50) ? 1 : 0; // 50Hz threshold
      currentByte |= (bit << bitCount);
      bitCount++;

      if (bitCount == 8) {
        data.add(currentByte);
        currentByte = 0;
        bitCount = 0;
      }
    }

    return data;
  }

  String? _decodeNodeId(List<double> frequencies) {
    final data = _decodeData(frequencies);
    if (data == null || data.length < 6) return null; // 6 bytes za ID

    return data
        .take(6)
        .map((e) => e.toRadixString(16).padLeft(2, '0'))
        .join(':');
  }

  double _calculateSignalStrength(double amplitude) {
    // Normalizuj amplitudu na 0-1 skalu
    return (amplitude - MIN_AMPLITUDE) / (1 - MIN_AMPLITUDE);
  }

  Stream<List<int>> get dataStream => _dataStreamController.stream;

  void dispose() {
    stopListening();
    _dataStreamController.close();
  }
}
