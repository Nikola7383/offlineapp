import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'token_encryption.dart';
import 'package:qr/qr.dart';

/// Generator QR kodova za verifikaciju
class QRCodeGenerator {
  // Konstante za QR kod
  static const double DEFAULT_SIZE = 200.0;
  static const int DEFAULT_VERSION = 4;
  static const int DEFAULT_ERROR_CORRECTION = QrErrorCorrectLevel.M;

  /// Generiše QR kod widget za verifikacioni token
  static Widget generateQRCode(
    VerificationToken token, {
    double size = DEFAULT_SIZE,
    int version = DEFAULT_VERSION,
    int errorCorrectionLevel = DEFAULT_ERROR_CORRECTION,
  }) {
    return QrImageView(
      data: token.qrData,
      version: version,
      errorCorrectionLevel: errorCorrectionLevel,
      size: size,
      backgroundColor: Colors.white,
      padding: const EdgeInsets.all(20),
      embeddedImage: const AssetImage('assets/logo.png'),
      embeddedImageStyle: const QrEmbeddedImageStyle(
        size: Size(40, 40),
      ),
    );
  }

  /// Generiše QR kod kao Image widget
  static Widget generateQRImage(
    VerificationToken token, {
    double size = DEFAULT_SIZE,
    int version = DEFAULT_VERSION,
    int errorCorrectionLevel = DEFAULT_ERROR_CORRECTION,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: QrImageView(
        data: token.qrData,
        version: version,
        errorCorrectionLevel: errorCorrectionLevel,
        size: size - 40, // Umanji za padding
        backgroundColor: Colors.white,
        padding: const EdgeInsets.all(20),
        embeddedImage: const AssetImage('assets/logo.png'),
        embeddedImageStyle: const QrEmbeddedImageStyle(
          size: Size(30, 30),
        ),
      ),
    );
  }

  /// Generiše animirani QR kod koji se menja tokom vremena
  static Widget generateAnimatedQRCode(
    VerificationToken token, {
    double size = DEFAULT_SIZE,
    int version = DEFAULT_VERSION,
    int errorCorrectionLevel = DEFAULT_ERROR_CORRECTION,
    Duration animationDuration = const Duration(milliseconds: 500),
  }) {
    return AnimatedContainer(
      duration: animationDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: QrImageView(
        data: token.qrData,
        version: version,
        errorCorrectionLevel: errorCorrectionLevel,
        size: size - 40,
        backgroundColor: Colors.white,
        padding: const EdgeInsets.all(20),
        embeddedImage: const AssetImage('assets/logo.png'),
        embeddedImageStyle: const QrEmbeddedImageStyle(
          size: Size(30, 30),
        ),
      ),
    );
  }

  /// Generiše QR kod sa custom stilom
  static Widget generateStyledQRCode(
    VerificationToken token, {
    double size = DEFAULT_SIZE,
    int version = DEFAULT_VERSION,
    int errorCorrectionLevel = DEFAULT_ERROR_CORRECTION,
    Color backgroundColor = Colors.white,
    Color foregroundColor = Colors.black,
    EdgeInsets padding = const EdgeInsets.all(20),
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
    Widget? overlay,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(10),
        boxShadow: boxShadow ??
            const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          QrImageView(
            data: token.qrData,
            version: version,
            errorCorrectionLevel: errorCorrectionLevel,
            size: size - padding.horizontal,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            padding: padding,
            embeddedImage: const AssetImage('assets/logo.png'),
            embeddedImageStyle: const QrEmbeddedImageStyle(
              size: Size(30, 30),
            ),
          ),
          if (overlay != null) overlay,
        ],
      ),
    );
  }
}
