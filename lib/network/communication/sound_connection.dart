import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import 'network_communicator.dart';
import 'fft.dart';

/// Upravlja zvučnom komunikacijom sa čvorom
class SoundConnection implements NodeConnection {
  @override
  final String nodeId;

  // Kontroleri za zvuk
  final _player = FlutterSoundPlayer();
  final _recorder = FlutterSoundRecorder();

  // Stream controller za primljene poruke
  final _messageController = StreamController<NetworkMessage>.broadcast();

  // Status konekcije
  bool _isInitialized = false;
  bool _isTransmitting = false;
  bool _isReceiving = false;

  // Konstante
  static const Duration TRANSMISSION_TIMEOUT = Duration(seconds: 30);
  static const int SAMPLE_RATE = 44100;
  static const int CHUNK_SIZE = 1024;
  static const int FREQUENCY_START = 18000; // 18kHz
  static const int FREQUENCY_STEP = 100; // 100Hz razmak
  static const int FREQUENCIES_COUNT = 16; // 16 različitih frekvencija
  static const double SIGNAL_THRESHOLD = 0.1; // Prag za detekciju signala

  Stream<NetworkMessage> get messageStream => _messageController.stream;

  SoundConnection({
    required this.nodeId,
  });

  /// Inicijalizuje zvučnu komunikaciju
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Inicijalizuj player
      await _player.openPlayer();
      await _player.setSubscriptionDuration(Duration(milliseconds: 10));

      // Inicijalizuj recorder
      await _recorder.openRecorder();
      await _recorder.setSubscriptionDuration(Duration(milliseconds: 10));

      _isInitialized = true;
      return true;
    } catch (e) {
      print('Greška pri inicijalizaciji zvučne komunikacije: $e');
      return false;
    }
  }

  /// Šalje podatke kroz zvučni kanal
  Future<bool> _transmitData(Uint8List data) async {
    if (!_isInitialized) return false;
    if (_isTransmitting) return false;

    _isTransmitting = true;

    try {
      // Konvertuj podatke u frekvencije
      final frequencies = _encodeData(data);

      // Generiši zvučni signal
      final signal = _generateSignal(frequencies);

      // Reprodukuj signal
      await _player.startPlayer(
        fromDataBuffer: signal.buffer.asUint8List(),
        sampleRate: SAMPLE_RATE,
        numChannels: 1,
      );

      // Sačekaj da se završi reprodukcija
      await _player.stopPlayer();

      _isTransmitting = false;
      return true;
    } catch (e) {
      print('Greška pri slanju zvučnog signala: $e');
      _isTransmitting = false;
      return false;
    }
  }

  /// Prima podatke kroz zvučni kanal
  Future<Uint8List?> _receiveData() async {
    if (!_isInitialized) return null;
    if (_isReceiving) return null;

    _isReceiving = true;

    try {
      // Pokreni snimanje
      await _recorder.startRecorder(
        toStream: true,
        codec: Codec.pcm16,
        numChannels: 1,
        sampleRate: SAMPLE_RATE,
      );

      final buffer = <double>[];
      var signalDetected = false;
      var silenceCount = 0;

      // Pretplati se na audio stream
      await for (final data in _recorder.onProgress!) {
        if (data.duration >= TRANSMISSION_TIMEOUT) break;

        // Konvertuj audio podatke u samples
        final samples = _convertToSamples(data.audioData!);

        // Proveri da li je detektovan signal
        if (!signalDetected) {
          final rms = _calculateRMS(samples);
          if (rms > SIGNAL_THRESHOLD) {
            signalDetected = true;
            buffer.addAll(samples);
          }
          continue;
        }

        buffer.addAll(samples);

        // Proveri da li je signal završen
        final rms = _calculateRMS(samples);
        if (rms < SIGNAL_THRESHOLD) {
          silenceCount++;
          if (silenceCount >= 3) break; // 3 uzastopna tiha chunk-a
        } else {
          silenceCount = 0;
        }
      }

      // Zaustavi snimanje
      await _recorder.stopRecorder();

      if (!signalDetected || buffer.isEmpty) {
        _isReceiving = false;
        return null;
      }

      // Dekodiraj primljene podatke
      final frequencies = _detectFrequencies(buffer);
      final data = _decodeData(frequencies);

      _isReceiving = false;
      return data;
    } catch (e) {
      print('Greška pri primanju zvučnog signala: $e');
      _isReceiving = false;
      return null;
    }
  }

  /// Konvertuje podatke u niz frekvencija
  List<int> _encodeData(Uint8List data) {
    final frequencies = <int>[];

    for (var byte in data) {
      // Konvertuj svaki bajt u dve frekvencije (4 bita po frekvenciji)
      frequencies.add(FREQUENCY_START + (byte >> 4) * FREQUENCY_STEP);
      frequencies.add(FREQUENCY_START + (byte & 0x0F) * FREQUENCY_STEP);
    }

    return frequencies;
  }

  /// Konvertuje niz frekvencija nazad u podatke
  Uint8List _decodeData(List<int> frequencies) {
    final data = <int>[];

    for (var i = 0; i < frequencies.length; i += 2) {
      // Konvertuj svaki par frekvencija nazad u bajt
      final highNibble = (frequencies[i] - FREQUENCY_START) ~/ FREQUENCY_STEP;
      final lowNibble =
          (frequencies[i + 1] - FREQUENCY_START) ~/ FREQUENCY_STEP;
      data.add((highNibble << 4) | lowNibble);
    }

    return Uint8List.fromList(data);
  }

  /// Generiše zvučni signal za date frekvencije
  Float32List _generateSignal(List<int> frequencies) {
    final signal = Float32List(SAMPLE_RATE ~/ 10); // 100ms po frekvenciji
    final samplesPerFreq = signal.length ~/ frequencies.length;

    for (var i = 0; i < frequencies.length; i++) {
      final freq = frequencies[i];
      final start = i * samplesPerFreq;
      final end = start + samplesPerFreq;

      for (var j = start; j < end; j++) {
        final t = j / SAMPLE_RATE;
        signal[j] = sin(2 * pi * freq * t);
      }
    }

    return signal;
  }

  /// Konvertuje audio podatke u samples
  List<double> _convertToSamples(Uint8List audioData) {
    final samples = <double>[];

    for (var i = 0; i < audioData.length; i += 2) {
      final sample = (audioData[i] | (audioData[i + 1] << 8)) / 32768.0;
      samples.add(sample);
    }

    return samples;
  }

  /// Detektuje frekvencije u audio signalu
  List<int> _detectFrequencies(List<double> samples) {
    final frequencies = <int>[];
    final samplesPerChunk = SAMPLE_RATE ~/ 10; // 100ms po frekvenciji

    for (var i = 0; i < samples.length; i += samplesPerChunk) {
      final chunk = samples.sublist(
        i,
        min(i + samplesPerChunk, samples.length),
      );

      // Dopuni chunk nulama do sledeće stepena dvojke
      final paddedSize = _nextPowerOfTwo(chunk.length);
      final paddedChunk = List<double>.filled(paddedSize, 0.0);
      paddedChunk.setRange(0, chunk.length, chunk);

      // Izračunaj FFT
      final fft = FFT.transform(paddedChunk);

      // Pronađi dominantnu frekvenciju
      final freq = FFT.findDominantFrequency(fft, SAMPLE_RATE);

      // Dodaj frekvenciju ako je u očekivanom opsegu
      if (freq >= FREQUENCY_START &&
          freq < FREQUENCY_START + FREQUENCIES_COUNT * FREQUENCY_STEP) {
        frequencies.add(freq);
      }
    }

    return frequencies;
  }

  /// Izračunava RMS (Root Mean Square) vrednost za samples
  double _calculateRMS(List<double> samples) {
    if (samples.isEmpty) return 0.0;

    var sum = 0.0;
    for (var sample in samples) {
      sum += sample * sample;
    }

    return sqrt(sum / samples.length);
  }

  /// Pronalazi sledeći stepen dvojke
  int _nextPowerOfTwo(int n) {
    var power = 1;
    while (power < n) {
      power *= 2;
    }
    return power;
  }

  @override
  Future<bool> send(NetworkMessage message) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return false;
    }

    try {
      final data = _serializeMessage(message);
      return await _transmitData(data);
    } catch (e) {
      print('Greška pri slanju poruke: $e');
      return false;
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

  @override
  Future<void> close() async {
    _isInitialized = false;
    await _player.closePlayer();
    await _recorder.closeRecorder();
    await _messageController.close();
  }
}
