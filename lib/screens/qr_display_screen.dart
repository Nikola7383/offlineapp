import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../verification/token_encryption.dart';
import '../verification/qr_code_generator.dart';
import '../sound/sound_qr_integration_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Ekran za prikaz QR koda
class QRDisplayScreen extends ConsumerStatefulWidget {
  final VerificationToken token;

  const QRDisplayScreen({
    super.key,
    required this.token,
  });

  @override
  ConsumerState<QRDisplayScreen> createState() => _QRDisplayScreenState();
}

class _QRDisplayScreenState extends ConsumerState<QRDisplayScreen> {
  bool _isAnimating = false;
  bool _isSoundEnabled = false;

  @override
  Widget build(BuildContext context) {
    final soundManager = ref.watch(soundQRIntegrationManagerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Kod'),
        actions: [
          IconButton(
            icon: Icon(_isSoundEnabled ? Icons.volume_up : Icons.volume_off),
            onPressed: () => _toggleSound(soundManager),
          ),
          IconButton(
            icon: Icon(_isAnimating ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              setState(() {
                _isAnimating = !_isAnimating;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: _isAnimating
                    ? QRCodeGenerator.generateAnimatedQRCode(
                        widget.token,
                        size: 300,
                        animationDuration: const Duration(seconds: 1),
                      )
                    : QRCodeGenerator.generateStyledQRCode(
                        widget.token,
                        size: 300,
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                        overlay: Positioned(
                          bottom: 16,
                          child: SvgPicture.asset(
                            'assets/logo.svg',
                            width: 40,
                            height: 40,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Token važi do:',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.token.validUntil.toLocal().toString(),
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                if (_isSoundEnabled) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Zvučni signal je aktivan',
                    style: TextStyle(color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Zatvori'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleSound(SoundQRIntegrationManager soundManager) async {
    if (_isSoundEnabled) {
      setState(() => _isSoundEnabled = false);
      return;
    }

    try {
      setState(() => _isSoundEnabled = true);

      // Emituj token kao zvučni signal
      await soundManager.emitToken(widget.token);

      if (!mounted) return;

      // Prikaži snackbar sa porukom o uspehu
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Zvučni signal je poslat'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSoundEnabled = false);

      // Prikaži snackbar sa greškom
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Greška pri slanju zvučnog signala: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
