import 'package:flutter/material.dart';
import 'package:secure_event_app/core/core.dart';

class InitialSetupScreen extends StatefulWidget {
  const InitialSetupScreen({super.key});

  @override
  State<InitialSetupScreen> createState() => _InitialSetupScreenState();
}

class _InitialSetupScreenState extends State<InitialSetupScreen> {
  final _logger = LoggerService();
  bool _isInitializing = false;

  Future<void> _initializeApp() async {
    setState(() => _isInitializing = true);

    try {
      // Initialize core services
      await _initializeCoreServices();

      // Initialize security
      await _initializeSecurity();

      // Initialize network
      await _initializeNetwork();
    } catch (e, stack) {
      _logger.error('Initialization failed', {'error': e, 'stack': stack});
    } finally {
      setState(() => _isInitializing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isInitializing
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _initializeApp,
                child: const Text('Initialize App'),
              ),
      ),
    );
  }
}
