import 'package:flutter/foundation.dart';
import 'package:secure_event_app/core/core.dart';

class AppState extends ChangeNotifier {
  final LoggerService _logger;
  bool _isInitialized = false;
  bool _isEmergencyMode = false;

  AppState({
    required LoggerService logger,
  }) : _logger = logger;

  bool get isInitialized => _isInitialized;
  bool get isEmergencyMode => _isEmergencyMode;

  Future<void> initializeApp() async {
    try {
      _logger.info('Initializing app...');
      // Initialize core services
      await _initializeCoreServices();
      _isInitialized = true;
      notifyListeners();
    } catch (e, stack) {
      _logger.error('Failed to initialize app', {'error': e, 'stack': stack});
      rethrow;
    }
  }

  Future<void> activateEmergencyMode() async {
    try {
      _isEmergencyMode = true;
      notifyListeners();
      _logger.emergency('Emergency mode activated');
    } catch (e) {
      _logger.error('Failed to activate emergency mode', {'error': e});
      rethrow;
    }
  }
}
