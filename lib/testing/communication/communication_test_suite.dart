class CommunicationTestSuite {
  final CommunicationManager _manager;
  final LoggerService _logger;
  final TestDataGenerator _testData;

  CommunicationTestSuite({
    required CommunicationManager manager,
    required LoggerService logger,
    required TestDataGenerator testData,
  }) : _manager = manager,
       _logger = logger,
       _testData = testData;

  Future<void> runFullTest() async {
    try {
      _logger.info('\n=== POKRETANJE KOMUNIKACIONOG TESTA ===\n');

      // 1. Test inicijalizacije
      await _testInitialization();

      // 2. Test pojedinačnih kanala
      await _testIndividualChannels();

      // 3. Test integracije
      await _testChannelIntegration();

      // 4. Load test
      await _testUnderLoad();

      // 5. Recovery test
      await _testRecovery();

    } catch (e) {
      _logger.error('Test suite failed: $e');
      throw TestException('Communication test suite failed');
    }
  }

  Future<void> _testInitialization() async {
    _logger.info('Testing initialization...');
    
    try {
      await _manager.initializeAllChannels();
      _logger.info('✅ Initialization successful');
    } catch (e) {
      _logger.error('❌ Initialization failed: $e');
      throw TestException('Initialization failed');
    }
  }

  Future<void> _testIndividualChannels() async {
    _logger.info('\nTesting individual channels...');

    // Test messages
    final testMessages = await _testData.generateTestMessages(100);
    
    // Test results
    final results = {
      'bluetooth': await _testBluetoothChannel(testMessages),
      'sound': await _testSoundChannel(testMessages),
      'mesh': await _testMeshChannel(testMessages)
    };

    _displayChannelResults(results);
  }

  Future<TestResults> _testBluetoothChannel(List<Message> messages) async {
    _logger.info('\nTesting Bluetooth...');
    
    final results = TestResults();
    
    for (var msg in messages) {
      try {
        final start = DateTime.now();
        final success = await _manager.sendViaBluetooth(msg);
        final duration = DateTime.now().difference(start);

        results.addResult(success, duration);
        
        if (success) {
          _logger.debug('✅ Bluetooth message sent (${duration.inMilliseconds}ms)');
        } else {
          _logger.error('❌ Bluetooth message failed');
        }
      } catch (e) {
        results.addError(e.toString());
      }
    }

    return results;
  }

  // Slični testovi za Sound i Mesh...

  void _displayResults(Map<String, TestResults> results) {
    _logger.info('''
\n=== REZULTATI KOMUNIKACIONOG TESTA ===

1. BLUETOOTH
-----------
Success Rate: ${results['bluetooth']!.successRate}%
Avg Speed: ${results['bluetooth']!.averageSpeed}ms
Errors: ${results['bluetooth']!.errorCount}

2. SOUND
--------
Success Rate: ${results['sound']!.successRate}%
Avg Speed: ${results['sound']!.averageSpeed}ms
Errors: ${results['sound']!.errorCount}

3. MESH
-------
Success Rate: ${results['mesh']!.successRate}%
Avg Speed: ${results['mesh']!.averageSpeed}ms
Errors: ${results['mesh']!.errorCount}

=== PROBLEMI ===
${_formatProblems(results)}

=== PREPORUKE ===
${_generateRecommendations(results)}
''');
  }
}

// Pokretanje test suite-a
void main() async {
  final testSuite = CommunicationTestSuite(...);
  await testSuite.runFullTest();
} 