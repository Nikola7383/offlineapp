import 'dart:async';

class SecurityErrorHandler {
  static final SecurityErrorHandler _instance =
      SecurityErrorHandler._internal();

  final SecurityAuditManager _auditManager;
  final SecurityEventCoordinator _eventCoordinator;
  final SecurityLogger _logger;

  // Error streams za različite nivoe ozbiljnosti
  final StreamController<SecurityError> _criticalErrorStream =
      StreamController.broadcast();
  final StreamController<SecurityError> _highErrorStream =
      StreamController.broadcast();
  final StreamController<SecurityError> _mediumErrorStream =
      StreamController.broadcast();
  final StreamController<SecurityError> _lowErrorStream =
      StreamController.broadcast();

  factory SecurityErrorHandler() {
    return _instance;
  }

  SecurityErrorHandler._internal()
      : _auditManager = SecurityAuditManager(),
        _eventCoordinator = SecurityEventCoordinator(),
        _logger = SecurityLogger() {
    _initializeErrorHandling();
  }

  void _initializeErrorHandling() {
    // Monitoring critical grešaka
    _criticalErrorStream.stream.listen((error) async {
      await _handleCriticalError(error);
    });

    // Monitoring high grešaka
    _highErrorStream.stream.listen((error) async {
      await _handleHighSeverityError(error);
    });
  }

  Future<void> handleError(SecurityError error) async {
    try {
      // 1. Log error
      await _logger.logError(error);

      // 2. Audit log
      await _auditManager.logSecurityEvent(SecurityEvent(
          type: 'ERROR',
          priority: _mapSeverityToPriority(error.severity),
          data: error.toMap()));

      // 3. Emit error event
      await _eventCoordinator.handleEvent(SecurityEvent(
          type: 'SYSTEM_ERROR',
          priority: _mapSeverityToPriority(error.severity),
          data: error.toMap()));

      // 4. Stream error based on severity
      _streamError(error);

      // 5. Take action
      await _takeErrorAction(error);
    } catch (e) {
      // Fallback error handling
      print('Critical error in error handler: $e');

      // Pokušaj recovery
      await _performEmergencyRecovery(error, e);
    }
  }

  void _streamError(SecurityError error) {
    switch (error.severity) {
      case ErrorSeverity.critical:
        _criticalErrorStream.add(error);
        break;
      case ErrorSeverity.high:
        _highErrorStream.add(error);
        break;
      case ErrorSeverity.medium:
        _mediumErrorStream.add(error);
        break;
      case ErrorSeverity.low:
        _lowErrorStream.add(error);
        break;
    }
  }

  Future<void> _takeErrorAction(SecurityError error) async {
    switch (error.severity) {
      case ErrorSeverity.critical:
        await _handleCriticalError(error);
        break;
      case ErrorSeverity.high:
        await _handleHighSeverityError(error);
        break;
      case ErrorSeverity.medium:
        await _handleMediumSeverityError(error);
        break;
      case ErrorSeverity.low:
        await _handleLowSeverityError(error);
        break;
    }
  }

  Future<void> _handleCriticalError(SecurityError error) async {
    // 1. System shutdown sequence
    await _initiateSystemShutdown(error);

    // 2. Emergency backup
    await _performEmergencyBackup(error);

    // 3. Alert administrators
    await _alertAdministrators(error);

    // 4. Initiate recovery
    await _initiateSystemRecovery(error);
  }

  Priority _mapSeverityToPriority(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.critical:
        return Priority.critical;
      case ErrorSeverity.high:
        return Priority.high;
      case ErrorSeverity.medium:
        return Priority.normal;
      case ErrorSeverity.low:
        return Priority.low;
    }
  }

  Stream<SecurityError> get criticalErrors => _criticalErrorStream.stream;
  Stream<SecurityError> get highErrors => _highErrorStream.stream;
  Stream<SecurityError> get mediumErrors => _mediumErrorStream.stream;
  Stream<SecurityError> get lowErrors => _lowErrorStream.stream;
}

class SecurityError {
  final ErrorType type;
  final ErrorSeverity severity;
  final String message;
  final dynamic data;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  SecurityError(
      {required this.type,
      required this.severity,
      required this.message,
      this.data,
      this.stackTrace,
      DateTime? timestamp})
      : this.timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'type': type.toString(),
      'severity': severity.toString(),
      'message': message,
      'data': data,
      'stackTrace': stackTrace?.toString(),
      'timestamp': timestamp.toIso8601String()
    };
  }
}

enum ErrorType {
  initialization,
  dependencySetup,
  eventProcessing,
  eventHandling,
  handlerExecution,
  systemError
}

enum ErrorSeverity { low, medium, high, critical }
