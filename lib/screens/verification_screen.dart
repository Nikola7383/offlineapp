import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/verification/verification_provider.dart';
import '../sound/sound_qr_integration_manager.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  bool _isListeningForSound = false;

  @override
  Widget build(BuildContext context) {
    final verificationState = ref.watch(verificationProvider);
    final soundManager = ref.watch(soundQRIntegrationManagerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikacija'),
        actions: [
          IconButton(
            icon: Icon(_isListeningForSound ? Icons.mic : Icons.mic_none),
            onPressed: () => _toggleSoundListening(soundManager),
          ),
        ],
      ),
      body: Stack(
        children: [
          // QR Scanner
          MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                _handleBarcode(barcode.rawValue);
              }
            },
          ),

          // Overlay za status
          if (verificationState.isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Indikator zvučnog skeniranja
          if (_isListeningForSound)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Slušam zvučni signal...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _toggleSoundListening(
      SoundQRIntegrationManager soundManager) async {
    if (_isListeningForSound) {
      setState(() => _isListeningForSound = false);
      return;
    }

    setState(() => _isListeningForSound = true);

    try {
      final token = await soundManager.listenForToken();
      if (token != null) {
        await ref.read(verificationProvider.notifier).verifyToken(
              token.toEncryptedString(),
            );
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška pri zvučnoj verifikaciji: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isListeningForSound = false);
      }
    }
  }

  Future<void> _handleBarcode(String? rawValue) async {
    if (rawValue == null) return;

    try {
      await ref.read(verificationProvider.notifier).verifyToken(rawValue);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nevažeći QR kod: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
