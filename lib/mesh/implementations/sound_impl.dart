import 'dart:async';
import 'dart:math';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fftea/fftea.dart';
import '../models/sound_types.dart';

class SoundImpl implements Sound {
  static const int SAMPLE_RATE = 44100;
  static const int FFT_SIZE = 2048;

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  final StreamController<SoundData> _audioController =
      StreamController.broadcast();
  final FFT _fft = FFT(FFT_SIZE);

  bool _isInitialized = false;
  StreamSubscription? _recordingSubscription;

  @override
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  @override
  Future<void> startListening() async {
    if (!_isInitialized) {
      await _initialize();
    }

    await _recorder.startRecorder(
      toStream: true,
      codec: Codec.pcm16,
      numChannels: 1,
      sampleRate: SAMPLE_RATE,
    );

    _recordingSubscription = _recorder.onProgress!.listen((e) {
      if (e.decibels != null) {
        final amplitude = _decibelToAmplitude(e.decibels!);
        final frequencies = _analyzeFrequencies(e.buffer!);

        _audioController.add(SoundData(
          frequencies: frequencies,
          amplitude: amplitude,
        ));
      }
    });
  }

  @override
  Future<void> stopListening() async {
    await _recordingSubscription?.cancel();
    _recordingSubscription = null;
    await _recorder.stopRecorder();
  }

  @override
  Future<void> playFrequencies(
      List<double> frequencies, double baseFrequency) async {
    if (!_isInitialized) {
      await _initialize();
    }

    final samples = _generateToneSequence(frequencies, baseFrequency);
    final buffer = Float64List.fromList(samples);

    await _player.startPlayer(
      fromDataBuffer: buffer.buffer.asUint8List(),
      codec: Codec.pcm16,
      sampleRate: SAMPLE_RATE,
      numChannels: 1,
    );
  }

  @override
  Stream<SoundData> get audioStream => _audioController.stream;

  Future<void> _initialize() async {
    await _recorder.openRecorder();
    await _player.openPlayer();
    _isInitialized = true;
  }

  List<double> _analyzeFrequencies(Uint8List buffer) {
    // Konvertuj buffer u Float64List
    final samples = Float64List(buffer.length ~/ 2);
    for (var i = 0; i < samples.length; i++) {
      final low = buffer[i * 2];
      final high = buffer[i * 2 + 1];
      samples[i] = (high << 8 | low) / 32768.0;
    }

    // Primeni Hanning window
    for (var i = 0; i < samples.length; i++) {
      samples[i] *= 0.5 * (1 - cos(2 * pi * i / (samples.length - 1)));
    }

    // Izračunaj FFT
    final spectrum = _fft.forward(samples);

    // Nađi dominantne frekvencije
    final frequencies = <double>[];
    for (var i = 0; i < spectrum.length ~/ 2; i++) {
      final magnitude = sqrt(spectrum[i].real * spectrum[i].real +
          spectrum[i].imaginary * spectrum[i].imaginary);

      if (magnitude > 0.1) {
        // Threshold za šum
        final frequency = i * SAMPLE_RATE / FFT_SIZE;
        frequencies.add(frequency);
      }
    }

    return frequencies;
  }

  List<double> _generateToneSequence(
      List<double> frequencies, double baseFrequency) {
    final samples = <double>[];
    final duration = 0.1; // 100ms po frekvenciji
    final samplesPerFreq = (SAMPLE_RATE * duration).round();

    for (var freq in frequencies) {
      for (var i = 0; i < samplesPerFreq; i++) {
        final t = i / SAMPLE_RATE;
        samples.add(sin(2 * pi * freq * t));
      }
    }

    return samples;
  }

  double _decibelToAmplitude(double db) {
    return pow(10, db / 20).toDouble();
  }

  Future<void> dispose() async {
    await stopListening();
    await _recorder.closeRecorder();
    await _player.closePlayer();
    await _audioController.close();
  }
}
