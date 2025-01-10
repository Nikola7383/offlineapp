import 'dart:math' show sin, pi;
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import '../verification/token_encryption.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'fft_analyzer.dart';

/// Frekvencije koje koristimo za zvučnu komunikaciju
class SoundFrequencies {
  static const startMarker = 18000.0; // Hz
  static const endMarker = 19000.0; // Hz
  static const baseFrequency = 17000.0; // Hz
  static const frequencyStep = 100.0; // Hz
  static const duration = 100; // ms
  static const sampleRate = 44100; // Hz
}

/// Manager za integraciju zvučne i QR verifikacije
class SoundQRIntegrationManager {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final TokenEncryption _encryption;
  final FFTAnalyzer _fftAnalyzer = FFTAnalyzer();
  bool _isInitialized = false;

  SoundQRIntegrationManager(this._encryption);

  Future<void> initialize() async {
    if (!_isInitialized) {
      await _player.openPlayer();
      await _recorder.openRecorder();
      _isInitialized = true;
    }
  }

  /// Konvertuje token u niz frekvencija
  List<double> _tokenToFrequencies(VerificationToken token) {
    final frequencies = <double>[];
    final tokenData = _encryption.encryptToken(token);

    // Dodaj start marker
    frequencies.add(SoundFrequencies.startMarker);

    // Konvertuj svaki bajt u frekvenciju
    for (var byte in tokenData.codeUnits) {
      final freq = SoundFrequencies.baseFrequency +
          (byte * SoundFrequencies.frequencyStep);
      frequencies.add(freq);
    }

    // Dodaj end marker
    frequencies.add(SoundFrequencies.endMarker);

    return frequencies;
  }

  /// Konvertuje frekvencije nazad u token
  VerificationToken? _frequenciesToToken(List<double> frequencies) {
    try {
      // Proveri markere
      if (frequencies.first != SoundFrequencies.startMarker ||
          frequencies.last != SoundFrequencies.endMarker) {
        return null;
      }

      // Ukloni markere
      frequencies = frequencies.sublist(1, frequencies.length - 1);

      // Konvertuj frekvencije nazad u bajtove
      final bytes = frequencies.map((freq) {
        final byte = ((freq - SoundFrequencies.baseFrequency) /
                SoundFrequencies.frequencyStep)
            .round();
        return byte;
      }).toList();

      // Konvertuj bajtove u string
      final tokenData = String.fromCharCodes(bytes);

      // Dekodiraj token
      return _encryption.decryptToken(tokenData);
    } catch (e) {
      return null;
    }
  }

  /// Emituje token kao zvučni signal
  Future<void> emitToken(VerificationToken token) async {
    if (!_isInitialized) await initialize();

    final frequencies = _tokenToFrequencies(token);

    for (var freq in frequencies) {
      await _player.startPlayer(
        fromDataBuffer:
            Uint8List.fromList(_generateTone(freq, SoundFrequencies.duration)),
      );
      await Future.delayed(Duration(milliseconds: SoundFrequencies.duration));
    }
  }

  /// Sluša i dekodira zvučni signal
  Future<VerificationToken?> listenForToken() async {
    if (!_isInitialized) await initialize();

    try {
      await _recorder.startRecorder(
        toFile: 'sound_token.wav',
        codec: Codec.pcm16WAV,
      );

      // Slušaj 5 sekundi
      await Future.delayed(const Duration(seconds: 5));

      final path = await _recorder.stopRecorder();
      if (path == null) return null;

      // Učitaj i analiziraj snimljeni zvuk
      final buffer = await _player.readFileTo16BitPCM(path);
      if (buffer == null) return null;

      // Konvertuj buffer u listu uzoraka
      final samples = List<int>.from(buffer);

      // Izvrši FFT analizu
      final magnitudes = _fftAnalyzer.performFFT(samples);

      // Pronađi dominantne frekvencije
      final frequencies = _fftAnalyzer.findDominantFrequencies(
        magnitudes,
        SoundFrequencies.sampleRate.toDouble(),
      );

      // Konvertuj frekvencije nazad u token
      return _frequenciesToToken(frequencies);
    } catch (e) {
      return null;
    }
  }

  /// Generiše ton određene frekvencije i trajanja
  List<int> _generateTone(double frequency, int durationMs) {
    final samples = <int>[];
    final samplesCount = (SoundFrequencies.sampleRate * durationMs) ~/ 1000;

    for (var i = 0; i < samplesCount; i++) {
      final t = i / SoundFrequencies.sampleRate;
      final amplitude = 32767 * 0.5; // 50% maksimalne amplitude
      final sample = (amplitude * sin(2 * pi * frequency * t)).toInt();
      samples.add(sample);
    }

    return samples;
  }

  Future<void> dispose() async {
    if (_isInitialized) {
      await _player.closePlayer();
      await _recorder.closeRecorder();
      _isInitialized = false;
    }
  }
}

/// Provider za SoundQRIntegrationManager
final soundQRIntegrationManagerProvider =
    Provider<SoundQRIntegrationManager>((ref) {
  final encryption = TokenEncryption();
  return SoundQRIntegrationManager(encryption);
});
