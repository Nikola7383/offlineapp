import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'token_encryption.dart';
import 'qr_code_scanner.dart';

/// Verifikator QR kodova
class QRCodeVerifier {
  final TokenEncryption _encryption;
  final QRCodeScanner scanner;

  // Stream kontroler za status verifikacije
  final StreamController<VerificationStatus> _statusController =
      StreamController<VerificationStatus>.broadcast();

  // Status verifikacije
  bool _isVerifying = false;
  StreamSubscription? _scanSubscription;

  QRCodeVerifier(this._encryption) : scanner = QRCodeScanner();

  /// Stream za praćenje statusa verifikacije
  Stream<VerificationStatus> get verificationStatus => _statusController.stream;

  /// Započinje verifikaciju QR koda
  Future<void> startVerification(String expectedToken) async {
    if (_isVerifying) {
      throw StateError('Verifikacija je već u toku');
    }

    _isVerifying = true;
    _statusController.add(VerificationStatus.started);

    try {
      // Pretplati se na rezultate skeniranja
      _scanSubscription = scanner.scanResults.listen(
        (scannedData) async {
          try {
            // Proveri da li skenirani podatak počinje sa prefiksom
            if (!scannedData.startsWith(TokenEncryption.QR_PREFIX)) {
              _statusController.add(VerificationStatus.invalidFormat);
              return;
            }

            // Izdvoji JSON podatke
            final jsonStr =
                scannedData.substring(TokenEncryption.QR_PREFIX.length);
            final qrData = jsonDecode(jsonStr) as Map<String, dynamic>;

            // Proveri verziju
            final version = qrData['v'] as int;
            if (version != TokenEncryption.VERSION) {
              _statusController.add(VerificationStatus.invalidVersion);
              return;
            }

            // Izdvoji token i metadata
            final token = qrData['t'] as String;
            final metadata = qrData['m'] as Map<String, dynamic>;

            // Validiraj token
            final isValid = await _encryption.validateToken(
              token,
              expectedToken,
              context: 'qr_verification',
            );

            if (isValid) {
              _statusController.add(VerificationStatus.success);
              await stopVerification();
            } else {
              _statusController.add(VerificationStatus.invalidToken);
            }
          } catch (e) {
            print('Greška pri verifikaciji QR koda: $e');
            _statusController.add(VerificationStatus.error);
          }
        },
        onError: (error) {
          print('Greška pri skeniranju: $error');
          _statusController.add(VerificationStatus.error);
        },
      );
    } catch (e) {
      print('Greška pri pokretanju verifikacije: $e');
      _statusController.add(VerificationStatus.error);
      await stopVerification();
    }
  }

  /// Zaustavlja verifikaciju
  Future<void> stopVerification() async {
    if (!_isVerifying) return;

    _isVerifying = false;
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    await scanner.pause();
    _statusController.add(VerificationStatus.stopped);
  }

  /// Pauzira verifikaciju
  Future<void> pauseVerification() async {
    if (!_isVerifying) return;
    await scanner.pause();
    _statusController.add(VerificationStatus.paused);
  }

  /// Nastavlja verifikaciju
  Future<void> resumeVerification() async {
    if (!_isVerifying) return;
    await scanner.resume();
    _statusController.add(VerificationStatus.resumed);
  }

  /// Vraća skener widget
  Widget getScannerWidget({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Widget? overlay,
  }) {
    return scanner.buildScannerView(
      width: width,
      height: height,
      fit: fit,
      overlay: overlay,
    );
  }

  /// Oslobađa resurse
  void dispose() {
    _scanSubscription?.cancel();
    scanner.dispose();
    _statusController.close();
  }
}

/// Status verifikacije QR koda
enum VerificationStatus {
  started,
  paused,
  resumed,
  stopped,
  success,
  invalidFormat,
  invalidVersion,
  invalidToken,
  error,
}
