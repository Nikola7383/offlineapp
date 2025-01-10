import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'token_encryption.dart';

/// Skener za QR kodove
class QRCodeScanner {
  final MobileScannerController _controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
  );

  // Stream kontroler za rezultate skeniranja
  final StreamController<String> _scanResultController =
      StreamController<String>.broadcast();

  /// Stream za rezultate skeniranja
  Stream<String> get scanResults => _scanResultController.stream;

  /// Widget za prikaz skenera
  Widget buildScannerView({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Widget? overlay,
  }) {
    return Stack(
      children: [
        MobileScanner(
          controller: _controller,
          fit: fit,
          onDetect: _onDetect,
        ),
        if (overlay != null) overlay,
      ],
    );
  }

  /// Callback za detektovani QR kod
  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _scanResultController.add(barcode.rawValue!);
      }
    }
  }

  /// Pauzira skener
  Future<void> pause() async {
    await _controller.stop();
  }

  /// Nastavlja skeniranje
  Future<void> resume() async {
    await _controller.start();
  }

  /// Uključuje/isključuje blic
  Future<void> toggleTorch() async {
    await _controller.toggleTorch();
  }

  /// Menja kameru (prednja/zadnja)
  Future<void> switchCamera() async {
    await _controller.switchCamera();
  }

  /// Oslobađa resurse
  void dispose() {
    _controller.dispose();
    _scanResultController.close();
  }

  /// Kreira overlay za skener sa markerima
  static Widget buildOverlay({
    Color overlayColor = Colors.black54,
    double scanAreaSize = 200,
    Color scanAreaBorderColor = Colors.white,
    double scanAreaBorderWidth = 2.0,
    BorderRadius? scanAreaBorderRadius,
    Widget? customOverlay,
  }) {
    return Stack(
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            overlayColor,
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Center(
                child: Container(
                  width: scanAreaSize,
                  height: scanAreaSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        scanAreaBorderRadius ?? BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        Center(
          child: Container(
            width: scanAreaSize,
            height: scanAreaSize,
            decoration: BoxDecoration(
              border: Border.all(
                color: scanAreaBorderColor,
                width: scanAreaBorderWidth,
              ),
              borderRadius: scanAreaBorderRadius ?? BorderRadius.circular(12),
            ),
          ),
        ),
        if (customOverlay != null) customOverlay,
      ],
    );
  }

  /// Kreira animirani overlay za skener
  static Widget buildAnimatedOverlay({
    Color overlayColor = Colors.black54,
    double scanAreaSize = 200,
    Color scanAreaBorderColor = Colors.white,
    double scanAreaBorderWidth = 2.0,
    BorderRadius? scanAreaBorderRadius,
    Duration animationDuration = const Duration(seconds: 2),
    Widget? customOverlay,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Stack(
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                overlayColor,
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Center(
                    child: Container(
                      width: scanAreaSize,
                      height: scanAreaSize,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            scanAreaBorderRadius ?? BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.0),
                duration: animationDuration,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: scanAreaSize,
                      height: scanAreaSize,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: scanAreaBorderColor.withOpacity(2.0 - value),
                          width: scanAreaBorderWidth,
                        ),
                        borderRadius:
                            scanAreaBorderRadius ?? BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                onEnd: () => setState(() {}),
              ),
            ),
            if (customOverlay != null) customOverlay,
          ],
        );
      },
    );
  }
}
