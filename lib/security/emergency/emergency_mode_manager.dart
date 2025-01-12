import 'dart:async';

import 'package:injectable/injectable.dart';
import '../../core/interfaces/emergency_mode_interface.dart';
import '../../core/interfaces/logger_service_interface.dart';
import '../../models/emergency_options.dart';

@singleton
class EmergencyModeManager implements IEmergencyModeManager {
  final ILoggerService _logger;
  final _eventController = StreamController<EmergencyModeEvent>.broadcast();
  bool _isInitialized = false;
  bool _isActive = false;
  DateTime? _activatedAt;
  EmergencyOptions? _currentOptions;
  final List<String> _activeRestrictions = [];

  EmergencyModeManager(this._logger);

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      _logger.warning('EmergencyModeManager already initialized');
      return;
    }

    _logger.info('Initializing EmergencyModeManager');
    _isInitialized = true;
    _logger.info('EmergencyModeManager initialized');
  }

  @override
  Future<void> activate({required EmergencyOptions options}) async {
    if (!_isInitialized) {
      _logger.error('EmergencyModeManager not initialized');
      return;
    }

    if (_isActive) {
      _logger.warning('Emergency mode already active');
      return;
    }

    try {
      _logger.info('Activating emergency mode');
      _isActive = true;
      _activatedAt = DateTime.now();
      _currentOptions = options;

      // Primenjujemo restrikcije
      if (options.limitedOperations) {
        _activeRestrictions.add('limited_operations');
      }
      if (options.enhancedSecurity) {
        _activeRestrictions.add('enhanced_security');
      }
      if (options.preserveEssentialFunctions) {
        _activeRestrictions.add('essential_functions_only');
      }

      final event = EmergencyModeEvent(
        type: EmergencyEventType.activated,
        data: {
          'timestamp': _activatedAt!.toIso8601String(),
          'options': {
            'limitedOperations': options.limitedOperations,
            'enhancedSecurity': options.enhancedSecurity,
            'preserveEssentialFunctions': options.preserveEssentialFunctions,
            'timeout': options.timeout.inSeconds,
          },
        },
      );
      _eventController.add(event);

      _logger.info('Emergency mode activated successfully');
    } catch (e) {
      _isActive = false;
      _activatedAt = null;
      _currentOptions = null;
      _activeRestrictions.clear();
      _logger.error('Error activating emergency mode: ${e.toString()}');

      final event = EmergencyModeEvent(
        type: EmergencyEventType.error,
        data: {'error': e.toString()},
      );
      _eventController.add(event);
    }
  }

  @override
  Future<void> deactivate() async {
    if (!_isInitialized) {
      _logger.error('EmergencyModeManager not initialized');
      return;
    }

    if (!_isActive) {
      _logger.warning('Emergency mode not active');
      return;
    }

    try {
      _logger.info('Deactivating emergency mode');
      _isActive = false;
      _activatedAt = null;
      _currentOptions = null;
      _activeRestrictions.clear();

      final event = EmergencyModeEvent(
        type: EmergencyEventType.deactivated,
        data: {'timestamp': DateTime.now().toIso8601String()},
      );
      _eventController.add(event);

      _logger.info('Emergency mode deactivated successfully');
    } catch (e) {
      _logger.error('Error deactivating emergency mode: ${e.toString()}');

      final event = EmergencyModeEvent(
        type: EmergencyEventType.error,
        data: {'error': e.toString()},
      );
      _eventController.add(event);
    }
  }

  @override
  Future<bool> isActive() async {
    return _isActive;
  }

  @override
  Future<EmergencyModeReport> generateReport() async {
    if (!_isInitialized) {
      _logger.error('EmergencyModeManager not initialized');
      return EmergencyModeReport(
        isActive: false,
        activatedAt: DateTime.now(),
        currentOptions: EmergencyOptions(
          preserveEssentialFunctions: false,
          enhancedSecurity: false,
          limitedOperations: false,
        ),
        activeRestrictions: [],
        metadata: {'error': 'Manager not initialized'},
      );
    }

    return EmergencyModeReport(
      isActive: _isActive,
      activatedAt: _activatedAt ?? DateTime.now(),
      currentOptions: _currentOptions ??
          EmergencyOptions(
            preserveEssentialFunctions: false,
            enhancedSecurity: false,
            limitedOperations: false,
          ),
      activeRestrictions: List.from(_activeRestrictions),
      metadata: {
        'lastCheck': DateTime.now().toIso8601String(),
        'status': _isActive ? 'active' : 'inactive',
      },
    );
  }

  @override
  Stream<EmergencyModeEvent> get modeEvents => _eventController.stream;

  @override
  Future<void> dispose() async {
    await _eventController.close();
    _isInitialized = false;
    _isActive = false;
    _activatedAt = null;
    _currentOptions = null;
    _activeRestrictions.clear();
    _logger.info('EmergencyModeManager disposed');
  }
}
