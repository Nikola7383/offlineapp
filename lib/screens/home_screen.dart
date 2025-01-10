import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../verification/token_encryption.dart';
import '../providers/verification/verification_provider.dart';
import 'verification_screen.dart';
import 'qr_display_screen.dart';

/// Početni ekran aplikacije
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verificationState = ref.watch(verificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Event App'),
        centerTitle: true,
        actions: [
          if (verificationState.isOffline)
            const Icon(Icons.cloud_off, color: Colors.red)
          else
            const Icon(Icons.cloud_done, color: Colors.green),
        ],
      ),
      body: Column(
        children: [
          if (verificationState.error != null)
            Container(
              color: Colors.red.shade100,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                verificationState.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/logo.svg',
                      width: 120,
                      height: 120,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Dobrodošli u Secure Event App',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Izaberite opciju za verifikaciju',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    if (verificationState.lastVerificationTime != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Poslednja verifikacija: ${verificationState.lastVerificationTime!.toLocal()}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: verificationState.isLoading
                      ? null
                      : () => _generateAndShowQR(context, ref),
                  icon: const Icon(Icons.qr_code),
                  label: Text(
                    verificationState.isLoading
                        ? 'Generisanje...'
                        : 'Generiši QR kod',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: verificationState.isLoading
                      ? null
                      : () => _startVerification(context, ref),
                  icon: const Icon(Icons.camera_alt),
                  label: Text(
                    verificationState.isLoading
                        ? 'Skeniranje...'
                        : 'Skeniraj QR kod',
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateAndShowQR(BuildContext context, WidgetRef ref) async {
    try {
      final notifier = ref.read(verificationProvider.notifier);
      final token = await notifier.generateToken(
        context: 'home_screen',
        validity: const Duration(minutes: 5),
      );

      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => QRDisplayScreen(token: token),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška pri generisanju QR koda: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _startVerification(BuildContext context, WidgetRef ref) async {
    try {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const VerificationScreen(),
        ),
      );

      if (context.mounted && result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verifikacija uspešno završena'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška pri verifikaciji: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
