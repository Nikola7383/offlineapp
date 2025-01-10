class VerificationRunner {
  final SystemVerification _verification;
  final LoggerService _logger;

  VerificationRunner({
    required SystemVerification verification,
    required LoggerService logger,
  }) : _verification = verification,
       _logger = logger;

  Future<void> runVerification() async {
    try {
      _logger.info('\n=== POKRETANJE SISTEMSKE VERIFIKACIJE ===\n');
      
      // 1. Verifikacija core sistema
      await _verification.verifyFixes();
      
      // 2. Test komunikacije
      await _testCommunication();
      
      // 3. Test integracije
      await _testIntegration();
      
    } catch (e) {
      _logger.error('Verifikacija nije uspela: $e');
      throw VerificationException('Verification failed: $e');
    }
  }

  Future<void> _testCommunication() async {
    _logger.info('\n=== TESTIRANJE KOMUNIKACIJE ===\n');
    
    // Test Bluetooth
    final bluetoothStatus = await _testBluetooth();
    _logger.info('Bluetooth: ${_formatStatus(bluetoothStatus)}');
    
    // Test Sound
    final soundStatus = await _testSound();
    _logger.info('Sound: ${_formatStatus(soundStatus)}');
    
    // Test Mesh
    final meshStatus = await _testMesh();
    _logger.info('Mesh: ${_formatStatus(meshStatus)}');
  }

  Future<void> _testIntegration() async {
    _logger.info('\n=== TESTIRANJE INTEGRACIJE ===\n');
    
    // Test Security Integration
    final securityStatus = await _testSecurityIntegration();
    _logger.info('Security Integration: ${_formatStatus(securityStatus)}');
    
    // Test Data Flow
    final dataFlowStatus = await _testDataFlow();
    _logger.info('Data Flow: ${_formatStatus(dataFlowStatus)}');
  }

  String _formatStatus(TestStatus status) {
    return status.success ? '✅ RADI' : '❌ NE RADI (${status.error})';
  }
}

// Pokretanje verifikacije
void main() async {
  final runner = VerificationRunner(...);
  await runner.runVerification();
} 