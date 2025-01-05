import 'dart:async';
import '../event/mass_event_coordinator.dart';
import '../event/flexible_seed_system.dart';
import '../event/admin_seed_coordinator.dart';
import '../security/deep_protection/anti_tampering.dart';

class SystemIntegrator {
  final MassEventCoordinator eventCoordinator;
  final FlexibleSeedSystem seedSystem;
  final AdminSeedCoordinator adminCoordinator;
  final EnhancedProtocolCoordinator protocolCoordinator;

  final _metrics = IntegrationMetrics();
  final _monitor = SystemMonitor();
  final _emergency = EmergencyCoordinator();

  bool _isIntegrated = false;

  SystemIntegrator({
    required this.eventCoordinator,
    required this.seedSystem,
    required this.adminCoordinator,
    required this.protocolCoordinator,
  });

  Future<void> integrate() async {
    if (_isIntegrated) return;

    try {
      // 1. Osnovna integracija
      await _integrateCore();

      // 2. Bezbednosna integracija
      await _integrateSecurity();

      // 3. Monitoring integracija
      await _integrateMonitoring();

      // 4. Emergency integracija
      await _integrateEmergency();

      _isIntegrated = true;
    } catch (e) {
      await _handleIntegrationFailure(e);
    }
  }

  Future<void> _integrateCore() async {
    // Poveži seed sistem sa admin koordinatorom
    await _integrateSeedAndAdmin();

    // Poveži event sistem sa protokol koordinatorom
    await _integrateEventAndProtocol();

    // Verifikuj integraciju
    await _verifyCoreIntegration();
  }

  Future<void> _integrateSeedAndAdmin() async {
    // Postavi osluškivače za seed promene
    seedSystem.addListener((SeedEvent event) {
      if (event.type == SeedEventType.temporaryToPermament) {
        adminCoordinator.handleNewPermanentSeed(event.seed);
      }
    });

    // Postavi admin callbacks
    adminCoordinator.setCallbacks(
      onNewAdmin: seedSystem.handleNewAdmin,
      onAdminRemoved: seedSystem.handleRemovedAdmin,
    );

    // Optimizuj raspodelu seedova
    await _optimizeSeedDistribution();
  }

  Future<void> _integrateEventAndProtocol() async {
    // Poveži event routing sa protokolima
    eventCoordinator.setProtocolHandler(
      protocolCoordinator.handleProtocol,
    );

    // Postavi load balancing
    await _setupLoadBalancing();

    // Integriši failsafe mehanizme
    await _integrateFailsafe();
  }

  Future<void> _integrateSecurity() async {
    // Poveži sve security komponente
    await _secureAllChannels();

    // Postavi cross-component verifikaciju
    await _setupCrossVerification();

    // Integriši emergency protokole
    await _integrateSecurityEmergency();
  }

  Future<void> _integrateMonitoring() async {
    // Postavi centralni monitoring
    _monitor.initialize(
      components: [
        eventCoordinator,
        seedSystem,
        adminCoordinator,
        protocolCoordinator,
      ],
    );

    // Postavi alerting
    await _setupAlertSystem();

    // Konfiguriši metrike
    await _setupMetrics();
  }

  Future<void> _integrateEmergency() async {
    // Registruj emergency handlere
    _emergency.registerHandlers(
      onSystemFailure: _handleSystemFailure,
      onSecurityBreach: _handleSecurityBreach,
      onDataCorruption: _handleDataCorruption,
    );

    // Postavi recovery protokole
    await _setupRecoveryProtocols();

    // Verifikuj emergency sisteme
    await _verifyEmergencySystems();
  }

  Future<void> _handleIntegrationFailure(dynamic error) async {
    // Pokušaj rollback
    await _attemptRollback();

    // Aktiviraj fallback sisteme
    await _activateFallbackSystems();

    // Obavesti monitoring
    _monitor.reportCriticalError(error);

    throw IntegrationException(
      'Integration failed: $error',
      canRecover: await _canRecover(),
    );
  }

  Future<SystemStatus> getStatus() async {
    return SystemStatus(
      isIntegrated: _isIntegrated,
      components: await _getComponentStatuses(),
      metrics: await _metrics.getCurrentMetrics(),
      health: await _monitor.getSystemHealth(),
    );
  }
}
