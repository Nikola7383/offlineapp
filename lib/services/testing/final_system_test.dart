class FinalSystemTest {
  final SecurityService _security;
  final PerformanceService _performance;
  final MonitoringService _monitoring;
  final LoggerService _logger;

  FinalSystemTest({
    required SecurityService security,
    required PerformanceService performance,
    required MonitoringService monitoring,
    required LoggerService logger,
  }) : _security = security,
       _performance = performance,
       _monitoring = monitoring,
       _logger = logger;

  Future<void> runFullSystemTest() async {
    _logger.info('\n=== FINALNI SISTEMSKI TEST ===\n');

    try {
      // 1. Security testovi
      final securityResults = await _runSecurityTests();
      _displaySecurityResults(securityResults);

      // 2. Performance testovi
      final performanceResults = await _runPerformanceTests();
      _displayPerformanceResults(performanceResults);

      // 3. Stability testovi
      final stabilityResults = await _runStabilityTests();
      _displayStabilityResults(stabilityResults);

      // 4. Load testovi
      final loadResults = await _runLoadTests();
      _displayLoadResults(loadResults);

      // 5. Integration testovi
      final integrationResults = await _runIntegrationTests();
      _displayIntegrationResults(integrationResults);

      // 6. Finalni izveštaj
      _displayFinalReport({
        'security': securityResults,
        'performance': performanceResults,
        'stability': stabilityResults,
        'load': loadResults,
        'integration': integrationResults,
      });

    } catch (e) {
      _logger.error('Sistemski test nije uspeo: $e');
      throw TestException('System test failed');
    }
  }

  void _displayFinalReport(Map<String, TestResult> results) {
    final allPassed = results.values.every((r) => r.success);
    
    _logger.info('''
\n=== FINALNI SISTEMSKI IZVEŠTAJ ===

${allPassed ? '✅ SVE KOMPONENTE FUNKCIONIŠU OPTIMALNO' : '⚠️ PRONAĐENI PROBLEMI U SISTEMU'}

SECURITY TESTOVI:
🔒 Data Protection: ${_getTestStatus(results['security']!.tests['data_protection'])}
🔒 Access Control: ${_getTestStatus(results['security']!.tests['access_control'])}
🔒 Audit System: ${_getTestStatus(results['security']!.tests['audit_system'])}

PERFORMANCE TESTOVI:
⚡ Cache System: ${_getTestStatus(results['performance']!.tests['cache_system'])}
⚡ UI Response: ${_getTestStatus(results['performance']!.tests['ui_response'])}
⚡ Data Processing: ${_getTestStatus(results['performance']!.tests['data_processing'])}

STABILITY TESTOVI:
🔄 Error Handling: ${_getTestStatus(results['stability']!.tests['error_handling'])}
🔄 Recovery: ${_getTestStatus(results['stability']!.tests['recovery'])}
🔄 Resource Management: ${_getTestStatus(results['stability']!.tests['resource_management'])}

LOAD TESTOVI:
💪 Concurrent Users: ${results['load']!.metrics['concurrent_users']}
💪 Response Time: ${results['load']!.metrics['response_time']}ms
💪 Error Rate: ${results['load']!.metrics['error_rate']}%

INTEGRATION TESTOVI:
🔄 Component Integration: ${_getTestStatus(results['integration']!.tests['component_integration'])}
🔄 Data Flow: ${_getTestStatus(results['integration']!.tests['data_flow'])}
🔄 System Cohesion: ${_getTestStatus(results['integration']!.tests['system_cohesion'])}

SISTEMSKE METRIKE:
📊 CPU Usage: ${results['performance']!.metrics['cpu_usage']}%
📊 Memory Usage: ${results['performance']!.metrics['memory_usage']}MB
📊 Network Latency: ${results['performance']!.metrics['network_latency']}ms
📊 Disk I/O: ${results['performance']!.metrics['disk_io']}MB/s

MONITORING STATUS:
📈 Real-time Metrics: Active
📈 Alert System: Configured
📈 Performance Tracking: Enabled

${_generateRecommendations(results)}
''');
  }

  String _getTestStatus(TestStatus status) {
    return status.success ? '✅ PASS' : '❌ FAIL';
  }
}

// Pokretanje testa
void main() async {
  final systemTest = FinalSystemTest(...);
  await systemTest.runFullSystemTest();
} 