import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import '../security/encryption/encryption_service.dart';
import 'dart:convert';
import 'audio_signal_processor.dart';
import 'token_encryption.dart';
import 'dart:math';

/// Upravlja verifikacijom kroz kombinaciju zvuka i QR koda
class SoundQRVerification {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final EncryptionService _encryption;
  final AudioSignalProcessor _audioProcessor = AudioSignalProcessor();
  final TokenEncryption _tokenEncryption = TokenEncryption();

  // Konstante za zvučnu verifikaciju
  static const int SAMPLE_RATE = 44100;
  static const int CHANNELS = 1;
  static const Duration VERIFICATION_TIMEOUT = Duration(seconds: 30);
  static const int MAX_RETRIES = 3;
  static const Duration RETRY_DELAY = Duration(seconds: 2);

  // Status verifikacije
  bool _isInitialized = false;
  bool _isVerifying = false;

  // Trenutni token
  VerificationToken? _currentToken;

  SoundQRVerification(this._encryption);

  /// Inicijalizuje verifikaciju
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _player.openPlayer();
    await _recorder.openRecorder();

    _isInitialized = true;
  }

  /// Generiše novi verifikacioni token
  Future<VerificationToken> generateToken({
    String? context,
    Duration validity = const Duration(minutes: 5),
  }) async {
    if (!_isInitialized) {
      throw StateError('Verifikacija nije inicijalizovana');
    }

    // Generiši novi token sa enkripcijom
    _currentToken = await _tokenEncryption.generateToken(
      context: context,
      validity: validity,
    );

    return _currentToken!;
  }

  /// Započinje zvučnu verifikaciju
  Future<bool> startVerification(String qrToken) async {
    if (!_isInitialized) {
      throw StateError('Verifikacija nije inicijalizovana');
    }

    if (_isVerifying) {
      throw StateError('Verifikacija je već u toku');
    }

    if (_currentToken == null || !_currentToken!.isValid) {
      return false;
    }

    // Proveri validnost QR tokena
    if (!await _tokenEncryption.validateToken(
      qrToken,
      _currentToken!.token,
      context: 'qr_verification',
    )) {
      return false;
    }

    _isVerifying = true;
    var attempts = 0;

    try {
      while (attempts < MAX_RETRIES) {
        // Emituj zvučni signal
        final success =
            await _emitVerificationSound(_currentToken!.encryptedToken);
        if (success) {
          return true;
        }

        attempts++;
        if (attempts < MAX_RETRIES) {
          await Future.delayed(RETRY_DELAY);
        }
      }

      return false;
    } finally {
      _isVerifying = false;
    }
  }

  /// Osluškuje zvučnu verifikaciju
  Future<bool> listenForVerification(String expectedToken) async {
    if (!_isInitialized) {
      throw StateError('Verifikacija nije inicijalizovana');
    }

    if (_isVerifying) {
      throw StateError('Verifikacija je već u toku');
    }

    _isVerifying = true;
    final completer = Completer<bool>();

    try {
      // Započni snimanje
      await _recorder.startRecorder(
        codec: Codec.pcm16,
        numChannels: CHANNELS,
        sampleRate: SAMPLE_RATE,
      );

      // Postavi timeout
      Timer(VERIFICATION_TIMEOUT, () {
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      });

      // Osluškuj audio
      _recorder.onProgress!.listen((e) async {
        if (e.decibels != null && !completer.isCompleted) {
          final isValid = await _validateAudioSignal(
            e.decibels!,
            expectedToken,
          );
          if (isValid) {
            completer.complete(true);
          }
        }
      });

      return await completer.future;
    } finally {
      _isVerifying = false;
      await _recorder.stopRecorder();
    }
  }

  /// Emituje zvučni signal za verifikaciju
  Future<bool> _emitVerificationSound(String token) async {
    try {
      // Enkoduj token u audio signal
      final audioData = await _encodeToken(token);

      // Reprodukuj zvuk
      await _player.startPlayer(
        fromDataBuffer: audioData,
        codec: Codec.pcm16,
        numChannels: CHANNELS,
        sampleRate: SAMPLE_RATE,
      );

      // Sačekaj da se završi reprodukcija
      await _player.stopPlayer();
      return true;
    } catch (e) {
      print('Greška pri emitovanju zvuka: $e');
      return false;
    }
  }

  /// Validira primljeni audio signal
  Future<bool> _validateAudioSignal(
    double decibels,
    String expectedToken,
  ) async {
    try {
      // Konvertuj PCM u Float64List
      final buffer = await _recorder.stopRecorder();
      if (buffer == null) return false;

      // Konvertuj string u bajtove
      final bytes = Uint8List.fromList(buffer.codeUnits);

      // Konvertuj u Float64List
      final pcmData = Float64List(bytes.length ~/ 2);
      final byteData = ByteData.view(bytes.buffer);

      for (var i = 0; i < pcmData.length; i++) {
        pcmData[i] = byteData.getInt16(i * 2, Endian.little) / 32768.0;
      }

      // Analiziraj kvalitet signala
      final signalQuality = _audioProcessor.analyzeSignalQuality(pcmData);

      // Ako je signal preslab, prekini
      if (signalQuality < 0.5) return false;

      // Dekoduj podatke
      final decodedBytes = _audioProcessor.decodeData(pcmData);
      if (decodedBytes == null) return false;

      // Konvertuj u string i uporedi
      final decodedToken = utf8.decode(decodedBytes);

      // Validiraj token
      return await _tokenEncryption.validateToken(
        decodedToken,
        expectedToken,
        context: 'sound_verification',
      );
    } catch (e) {
      print('Greška pri validaciji audio signala: $e');
      return false;
    }
  }

  /// Enkoduje token u audio signal
  Future<Uint8List> _encodeToken(String token) async {
    final tokenBytes = utf8.encode(token);
    return _audioProcessor.encodeData(tokenBytes);
  }

  /// Oslobađa resurse
  Future<void> dispose() async {
    _isInitialized = false;
    _isVerifying = false;
    await _player.closePlayer();
    await _recorder.closeRecorder();
  }
}
