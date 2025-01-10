import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../encoder/sound_encoder.dart';
import '../../security/verification/qr_verification_manager.dart';
import '../../core/models/verification_result.dart';
import '../../security/encryption/encryption_service.dart';

/// Upravlja integracijom zvučne i QR verifikacije
/// Implementira fallback mehanizam i enkripciju zvučnog kanala
class SoundQRIntegrationManager {
  final SoundEncoder _soundEncoder;
  final QRVerificationManager _qrManager;
  final EncryptionService _encryptionService;

  bool _isInitialized = false;
  int _failedAttempts = 0;

  // Konstante
  static const int MAX_FAILED_ATTEMPTS = 3;
  static const Duration FALLBACK_TIMEOUT = Duration(seconds: 30);
  static const Duration COOLDOWN_PERIOD = Duration(minutes: 5);

  // Stanje fallback sistema
  DateTime? _lastFailure;
  VerificationMode _currentMode = VerificationMode.combined;

  SoundQRIntegrationManager({
    required SoundEncoder soundEncoder,
    required QRVerificationManager qrManager,
    required EncryptionService encryptionService,
  })  : _soundEncoder = soundEncoder,
        _qrManager = qrManager,
        _encryptionService = encryptionService;

  /// Inicijalizuje manager i proverava dostupnost hardvera
  Future<void> initialize() async {
    try {
      await _soundEncoder.initialize();
      await _qrManager.initialize();
      _isInitialized = true;
    } on PlatformException catch (e) {
      debugPrint('Greška pri inicijalizaciji: ${e.message}');
      rethrow;
    }
  }

  /// Generiše kombinovani verifikacioni token
  Future<String> generateVerificationToken({
    required String userId,
    required String role,
    Duration validity = const Duration(minutes: 5),
  }) async {
    if (!_isInitialized) throw Exception('Manager nije inicijalizovan');

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final tokenData = {
      'userId': userId,
      'role': role,
      'timestamp': timestamp,
      'validity': validity.inSeconds,
      'mode': _currentMode.toString(),
    };

    // Dodatna enkripcija za zvučni kanal
    final soundData = await _prepareSoundData(tokenData);
    final qrData = await _prepareQRData(tokenData);

    // Generiši tokene
    final soundToken = await _soundEncoder.encode(soundData);
    final qrToken = await _qrManager.generateToken(qrData);

    return _combineTokens(soundToken, qrToken);
  }

  /// Verifikuje token koristeći trenutni mod
  Future<VerificationResult> verifyToken(String combinedToken) async {
    if (!_isInitialized) throw Exception('Manager nije inicijalizovan');

    // Proveri cooldown period
    if (_isInCooldown) {
      return VerificationResult(
        isValid: false,
        errorMessage: 'Sistem je u cooldown periodu. Pokušajte kasnije.',
      );
    }

    try {
      switch (_currentMode) {
        case VerificationMode.combined:
          return await _verifyCombined(combinedToken);
        case VerificationMode.soundOnly:
          return await _verifySound(combinedToken);
        case VerificationMode.qrOnly:
          return await _verifyQR(combinedToken);
      }
    } catch (e) {
      _handleVerificationFailure();
      return VerificationResult(
        isValid: false,
        errorMessage: 'Verifikacija nije uspela: $e',
      );
    }
  }

  /// Verifikuje token koristeći oba kanala
  Future<VerificationResult> _verifyCombined(String combinedToken) async {
    final (soundToken, qrToken) = _splitTokens(combinedToken);

    // Prvo pokušaj zvučnu verifikaciju
    final soundResult = await _verifySound(soundToken);
    if (soundResult.isValid) {
      // Ako zvuk uspe, proveri i QR
      final qrResult = await _verifyQR(qrToken);
      if (qrResult.isValid) {
        _resetFailures(); // Uspešna verifikacija
        return VerificationResult(
          isValid: true,
          data: {...soundResult.data!, ...qrResult.data!},
        );
      }
    }

    // Ako bilo koji kanal ne uspe, prebaci se na fallback
    return await _handleFailureAndFallback(combinedToken);
  }

  /// Verifikuje samo zvučni token
  Future<VerificationResult> _verifySound(String token) async {
    try {
      final decodedData = await _soundEncoder.decode(token);
      final decryptedData = await _decryptSoundData(decodedData);
      return _validateTokenData(decryptedData, VerificationMode.soundOnly);
    } catch (e) {
      return VerificationResult(
        isValid: false,
        errorMessage: 'Zvučna verifikacija nije uspela: $e',
      );
    }
  }

  /// Verifikuje samo QR token
  Future<VerificationResult> _verifyQR(String token) async {
    try {
      return await _qrManager.verifyToken(token);
    } catch (e) {
      return VerificationResult(
        isValid: false,
        errorMessage: 'QR verifikacija nije uspela: $e',
      );
    }
  }

  /// Priprema podatke za zvučni kanal sa dodatnom enkripcijom
  Future<String> _prepareSoundData(Map<String, dynamic> data) async {
    final soundSpecificData = {
      ...data,
      'channel': 'sound',
      'nonce': DateTime.now().millisecondsSinceEpoch,
    };

    // Dodatna enkripcija za zvučni kanal
    final key = await _encryptionService.generateSecureKey();
    final encrypted = await _encryptionService.encrypt(
      soundSpecificData.toString(),
      key: key,
      algorithm: 'AES-256-GCM',
    );

    return '$encrypted:$key'; // Ključ se šalje zajedno sa podacima
  }

  /// Priprema podatke za QR kanal
  Future<String> _prepareQRData(Map<String, dynamic> data) async {
    final qrSpecificData = {
      ...data,
      'channel': 'qr',
      'nonce': DateTime.now().millisecondsSinceEpoch,
    };

    return await _encryptionService.encrypt(
      qrSpecificData.toString(),
      algorithm: 'AES-256-CBC',
    );
  }

  /// Dekriptuje podatke iz zvučnog kanala
  Future<String> _decryptSoundData(String data) async {
    final parts = data.split(':');
    if (parts.length != 2) {
      throw FormatException('Neispravan format zvučnih podataka');
    }

    return await _encryptionService.decrypt(
      parts[0],
      key: parts[1],
      algorithm: 'AES-256-GCM',
    );
  }

  /// Obrađuje neuspeh verifikacije i primenjuje fallback
  Future<VerificationResult> _handleFailureAndFallback(
      String combinedToken) async {
    _handleVerificationFailure();

    // Ako smo prešli limit pokušaja, aktiviraj fallback
    if (_failedAttempts >= MAX_FAILED_ATTEMPTS) {
      _activateFallback();

      // Pokušaj verifikaciju sa fallback modom
      switch (_currentMode) {
        case VerificationMode.soundOnly:
          final (soundToken, _) = _splitTokens(combinedToken);
          return await _verifySound(soundToken);
        case VerificationMode.qrOnly:
          final (_, qrToken) = _splitTokens(combinedToken);
          return await _verifyQR(qrToken);
        default:
          return VerificationResult(
            isValid: false,
            errorMessage: 'Neispravan verifikacioni mod',
          );
      }
    }

    return VerificationResult(
      isValid: false,
      errorMessage: 'Verifikacija nije uspela',
    );
  }

  /// Aktivira fallback mod
  void _activateFallback() {
    _lastFailure = DateTime.now();

    // Odaberi fallback mod na osnovu prethodnih rezultata
    if (_isSoundMoreReliable) {
      _currentMode = VerificationMode.soundOnly;
    } else {
      _currentMode = VerificationMode.qrOnly;
    }
  }

  /// Proverava da li je sistem u cooldown periodu
  bool get _isInCooldown {
    if (_lastFailure == null) return false;
    return DateTime.now().difference(_lastFailure!) < COOLDOWN_PERIOD;
  }

  /// Proverava koji kanal je pouzdaniji
  bool get _isSoundMoreReliable {
    // TODO: Implementirati praćenje uspešnosti kanala
    return true;
  }

  /// Beleži neuspeh verifikacije
  void _handleVerificationFailure() {
    _failedAttempts++;
    if (_failedAttempts >= MAX_FAILED_ATTEMPTS) {
      _lastFailure = DateTime.now();
    }
  }

  /// Resetuje brojač neuspeha
  void _resetFailures() {
    _failedAttempts = 0;
    _lastFailure = null;
    _currentMode = VerificationMode.combined;
  }

  /// Interno kombinuje sound i QR tokene
  String _combineTokens(String soundToken, String qrToken) {
    return '$soundToken:::$qrToken';
  }

  /// Razdvaja kombinovani token
  (String soundToken, String qrToken) _splitTokens(String combinedToken) {
    final parts = combinedToken.split(':::');
    if (parts.length != 2) {
      throw FormatException('Neispravan format tokena');
    }
    return (parts[0], parts[1]);
  }

  /// Validira podatke iz tokena
  VerificationResult _validateTokenData(String data, VerificationMode mode) {
    try {
      // Parsiraj podatke
      final Map<String, dynamic> tokenData = json.decode(data);

      // Proveri obavezna polja
      if (!tokenData.containsKey('userId') ||
          !tokenData.containsKey('role') ||
          !tokenData.containsKey('timestamp') ||
          !tokenData.containsKey('validity')) {
        return VerificationResult(
          isValid: false,
          errorMessage: 'Nedostaju obavezna polja u tokenu',
        );
      }

      // Proveri timestamp i validnost
      final timestamp = tokenData['timestamp'] as int;
      final validity = tokenData['validity'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (now - timestamp > validity * 1000) {
        return VerificationResult(
          isValid: false,
          errorMessage: 'Token je istekao',
        );
      }

      // Proveri kanal
      final channel = tokenData['channel'] as String?;
      if (channel != null) {
        switch (mode) {
          case VerificationMode.soundOnly:
            if (channel != 'sound') {
              return VerificationResult(
                isValid: false,
                errorMessage: 'Neispravan kanal za zvučnu verifikaciju',
              );
            }
            break;
          case VerificationMode.qrOnly:
            if (channel != 'qr') {
              return VerificationResult(
                isValid: false,
                errorMessage: 'Neispravan kanal za QR verifikaciju',
              );
            }
            break;
          default:
            break;
        }
      }

      // Sve je u redu
      return VerificationResult(
        isValid: true,
        data: tokenData,
      );
    } catch (e) {
      return VerificationResult(
        isValid: false,
        errorMessage: 'Validacija podataka nije uspela: $e',
      );
    }
  }
}

/// Modovi verifikacije
enum VerificationMode {
  combined, // Koristi oba kanala
  soundOnly, // Koristi samo zvučni kanal
  qrOnly, // Koristi samo QR kanal
}
