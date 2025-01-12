import 'dart:async';

import 'package:injectable/injectable.dart';
import '../../core/interfaces/system_state_interface.dart';
import '../../core/interfaces/logger_service_interface.dart';

@singleton
class SystemStateManager implements ISystemStateManager {
  final ILoggerService _logger;
  final _stateController = StreamController<SystemStateChange>.broadcast();
  bool _isInitialized = false;
  SystemMode _currentMode = SystemMode.normal;

  SystemStateManager(this._logger);

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      _logger.warning('SystemStateManager already initialized');
      return;
    }

    _logger.info('Initializing SystemStateManager');
    _isInitialized = true;
    _logger.info('SystemStateManager initialized');
  }

  @override
  Future<SystemState> getCurrentState() async {
    if (!_isInitialized) {
      _logger.error('SystemStateManager not initialized');
      return SystemState(
        isOperational: false,
        mode: SystemMode.normal,
        configuration: {},
        activeProcesses: [],
      );
    }

    return SystemState(
      isOperational: true,
      mode: _currentMode,
      configuration: {
        'securityLevel': 'high',
        'monitoringEnabled': true,
        'autoRecovery': true,
      },
      activeProcesses: [
        'security_monitor',
        'data_validator',
        'integrity_checker',
      ],
    );
  }

  @override
  Future<void> updateState(SystemState newState) async {
    if (!_isInitialized) {
      _logger.error('SystemStateManager not initialized');
      return;
    }

    try {
      _logger.info('Updating system state');
      final previousMode = _currentMode;
      _currentMode = newState.mode;

      final stateChange = SystemStateChange(
        previousMode: previousMode,
        newMode: newState.mode,
        reason: 'Manual state update',
        metadata: {
          'timestamp': DateTime.now().toIso8601String(),
          'isOperational': newState.isOperational.toString(),
        },
      );
      _stateController.add(stateChange);

      _logger.info('System state updated successfully');
    } catch (e) {
      _logger.error('Error updating system state: ${e.toString()}');
      _currentMode = SystemMode.normal;
    }
  }

  @override
  Stream<SystemStateChange> get stateChanges => _stateController.stream;

  @override
  Future<StateReport> generateReport() async {
    if (!_isInitialized) {
      _logger.error('SystemStateManager not initialized');
      return StateReport(
        isHealthy: false,
        issues: [],
        metadata: {'error': 'Manager not initialized'},
      );
    }

    try {
      _logger.info('Generating state report');

      // Simuliramo generisanje izveštaja
      await Future.delayed(Duration(seconds: 1));

      return StateReport(
        isHealthy: true,
        issues: [
          StateIssue(
            id: 'WARN_001',
            severity: StateSeverity.low,
            description: 'Routine state check warning',
            component: 'system/state/monitor',
          ),
        ],
        metadata: {
          'lastCheck': DateTime.now().toIso8601String(),
          'checkDuration': '1s',
          'currentMode': _currentMode.toString(),
        },
      );
    } catch (e) {
      _logger.error('Error generating state report: ${e.toString()}');
      return StateReport(
        isHealthy: false,
        issues: [
          StateIssue(
            id: 'ERR_001',
            severity: StateSeverity.critical,
            description: 'Report generation failed: ${e.toString()}',
            component: 'system',
          ),
        ],
        metadata: {'error': e.toString()},
      );
    }
  }

  @override
  Future<void> dispose() async {
    await _stateController.close();
    _isInitialized = false;
    _logger.info('SystemStateManager disposed');
  }
}
