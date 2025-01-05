void main() {
  group('Security Integration Layer Tests', () {
    late SecurityIntegrationLayer integrationLayer;
    late MockBluetoothOrchestrator mockBluetoothOrchestrator;
    late MockWifiOrchestrator mockWifiOrchestrator;
    late MockStateManager mockStateManager;
    late MockSecurityVault mockVault;
    late MockAIAnalyzer mockAiAnalyzer;
    late MockThreatDetection mockThreatDetection;

    setUp(() {
      mockBluetoothOrchestrator = MockBluetoothOrchestrator();
      mockWifiOrchestrator = MockWifiOrchestrator();
      mockStateManager = MockStateManager();
      mockVault = MockSecurityVault();
      mockAiAnalyzer = MockAIAnalyzer();
      mockThreatDetection = MockThreatDetection();

      integrationLayer = SecurityIntegrationLayer(
          bluetoothOrchestrator: mockBluetoothOrchestrator,
          wifiOrchestrator: mockWifiOrchestrator,
          stateManager: mockStateManager,
          securityVault: mockVault);
    });

    test('Advanced Systems Initialization Test', () async {
      when(mockAiAnalyzer.initialize(
              securityPolicies: any, threatPatterns: any, behaviorModels: any))
          .thenAnswer((_) async => true);

      await integrationLayer._initializeAdvancedSystems();

      verify(mockAiAnalyzer.initialize(
              securityPolicies: any, threatPatterns: any, behaviorModels: any))
          .called(1);
    });

    test('Threat Response Test', () async {
      final threat = SecurityThreat(
          type: ThreatType.unauthorized_access,
          severity: ThreatSeverity.high,
          source: 'test_device');

      final analysis = ThreatAnalysis(
          threat: threat,
          recommendedAction: SecurityAction.lockdown,
          confidence: 0.95);

      when(mockAiAnalyzer.analyzeThreat(threat))
          .thenAnswer((_) async => analysis);

      await integrationLayer
          ._handleSecurityIncident(SecurityIncident(threat: threat));

      verify(mockStateManager.activateEmergencyMode()).called(1);
    });

    test('Security Metrics Collection Test', () async {
      final metrics = SecurityMetrics(
          metrics: {'threat_level': 0.1, 'system_health': 0.95},
          timestamp: DateTime.now(),
          healthStatus: HealthStatus.healthy);

      when(mockAiAnalyzer.analyzeMetrics(metrics)).thenAnswer((_) async =>
          MetricsAnalysis(status: SystemStatus.normal, recommendations: []));

      expectLater(integrationLayer.collectSecurityMetrics(),
          emits(isA<SecurityMetrics>()));
    });

    test('Emergency Lockdown Test', () async {
      final strategy = SecurityStrategy(
          type: StrategyType.lockdown,
          details: {'reason': 'critical_threat'},
          priority: Priority.critical);

      await integrationLayer._executeLockdown(strategy);

      verify(mockBluetoothOrchestrator.stopAllCommunications()).called(1);
      verify(mockWifiOrchestrator.stopAllCommunications()).called(1);
      verify(mockVault.backupCriticalData()).called(1);
      verify(mockStateManager.activateEmergencyMode()).called(1);
    });

    test('AI Analysis Integration Test', () async {
      final incident = SecurityIncident(
          threat: SecurityThreat(
              type: ThreatType.suspicious_activity,
              severity: ThreatSeverity.medium,
              source: 'test_device'));

      when(mockAiAnalyzer.analyzeIncident(incident)).thenAnswer((_) async =>
          IncidentAnalysis(
              severity: IncidentSeverity.high,
              recommendedActions: [SecurityAction.isolate]));

      await integrationLayer._handleSecurityIncident(incident);

      verify(mockAiAnalyzer.analyzeIncident(incident)).called(1);
    });
  });
}
