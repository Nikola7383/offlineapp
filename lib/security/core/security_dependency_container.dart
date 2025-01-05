import 'dart:async';

class SecurityDependencyContainer {
  static final SecurityDependencyContainer _instance =
      SecurityDependencyContainer._internal();

  // Core komponente
  late final SecurityMasterController securityController;
  late final SystemEncryptionManager encryptionManager;
  late final SystemAuditManager auditManager;
  late final OfflineSecurityVault securityVault;
  late final SystemIntegrityProtectionManager integrityManager;
  late final SystemThreatProtectionManager threatManager;

  // Pomoćne komponente
  late final SecurityEventCoordinator eventCoordinator;
  late final SecurityErrorHandler errorHandler;
  late final SecurityLogger securityLogger;

  // Status
  bool _isInitialized = false;
  final StreamController<InitializationStatus> _initStatusController =
      StreamController.broadcast();

  factory SecurityDependencyContainer() {
    return _instance;
  }

  SecurityDependencyContainer._internal() {
    _initializeDependencies();
  }

  Future<void> _initializeDependencies() async {
    try {
      // Prvo inicijalizirati logger
      securityLogger = SecurityLogger();

      // Zatim nastaviti sa postojećom inicijalizacijom
      eventCoordinator = SecurityEventCoordinator();
      errorHandler = SecurityErrorHandler();

      await _initStatusController.add(InitializationStatus(
          phase: InitPhase.auxiliaryComponents, isComplete: true));

      // 2. Inicijalizacija core komponenti
      securityController = SecurityMasterController();
      encryptionManager = SystemEncryptionManager();
      auditManager = SystemAuditManager();
      securityVault = OfflineSecurityVault();
      integrityManager = SystemIntegrityProtectionManager();
      threatManager = SystemThreatProtectionManager();

      await _initStatusController.add(InitializationStatus(
          phase: InitPhase.coreComponents, isComplete: true));

      // 3. Setup međuzavisnosti
      await _setupDependencies();

      _isInitialized = true;

      await _initStatusController.add(
          InitializationStatus(phase: InitPhase.completed, isComplete: true));
    } catch (e) {
      await errorHandler.handleError(SecurityError(
          type: ErrorType.initialization,
          severity: ErrorSeverity.critical,
          message: 'Failed to initialize dependencies: $e'));
      rethrow;
    }
  }

  Future<void> _setupDependencies() async {
    try {
      // 1. Security Controller setup
      await securityController.initialize(
          encryptionManager: encryptionManager,
          auditManager: auditManager,
          securityVault: securityVault);

      // 2. Encryption Manager setup
      await encryptionManager.initialize(
          securityVault: securityVault, auditManager: auditManager);

      // 3. Audit Manager setup
      await auditManager.initialize(
          securityVault: securityVault, eventCoordinator: eventCoordinator);

      // 4. Security Vault setup
      await securityVault.initialize(
          encryptionManager: encryptionManager, auditManager: auditManager);

      // 5. Integrity Manager setup
      await integrityManager.initialize(
          securityVault: securityVault,
          auditManager: auditManager,
          threatManager: threatManager);

      // 6. Threat Manager setup
      await threatManager.initialize(
          securityVault: securityVault,
          auditManager: auditManager,
          integrityManager: integrityManager);
    } catch (e) {
      await errorHandler.handleError(SecurityError(
          type: ErrorType.dependencySetup,
          severity: ErrorSeverity.critical,
          message: 'Failed to setup dependencies: $e'));
      rethrow;
    }
  }

  bool get isInitialized => _isInitialized;

  Stream<InitializationStatus> get initializationStatus =>
      _initStatusController.stream;
}

class InitializationStatus {
  final InitPhase phase;
  final bool isComplete;
  final String? message;

  InitializationStatus(
      {required this.phase, required this.isComplete, this.message});
}

enum InitPhase {
  auxiliaryComponents,
  coreComponents,
  dependencySetup,
  completed
}
