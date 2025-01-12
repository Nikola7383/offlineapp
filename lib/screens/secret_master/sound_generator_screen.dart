import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SoundGeneratorScreen extends ConsumerStatefulWidget {
  const SoundGeneratorScreen({super.key});

  @override
  ConsumerState<SoundGeneratorScreen> createState() =>
      _SoundGeneratorScreenState();
}

class _SoundGeneratorScreenState extends ConsumerState<SoundGeneratorScreen> {
  bool isGenerating = false;
  bool isPlaying = false;

  Future<void> _generateSound() async {
    setState(() {
      isGenerating = true;
    });

    try {
      // TODO: Implementirati generisanje zvučnog signala
      await Future.delayed(const Duration(seconds: 2)); // Simulacija
      setState(() {
        isGenerating = false;
        isPlaying = true;
      });
    } catch (e) {
      setState(() {
        isGenerating = false;
        isPlaying = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _stopPlaying() {
    setState(() {
      isPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zvučni Generator'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Generisanje Zvučnog Signala',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isPlaying ? Colors.green : Colors.blue,
                      boxShadow: [
                        BoxShadow(
                          color: (isPlaying ? Colors.green : Colors.blue)
                              .withOpacity(0.3),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: isGenerating
                            ? null
                            : (isPlaying ? _stopPlaying : _generateSound),
                        child: Center(
                          child: isGenerating
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Icon(
                                  isPlaying ? Icons.stop : Icons.play_arrow,
                                  size: 64,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                isGenerating
                    ? 'Generisanje zvučnog signala...'
                    : isPlaying
                        ? 'Reprodukcija zvučnog signala'
                        : 'Pritisnite dugme za generisanje',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (isPlaying)
                const Text(
                  'Signal će se reprodukovati 30 sekundi',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
