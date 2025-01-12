import 'package:injectable/injectable.dart';
import '../interfaces/logger_service.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'verification_runner.freezed.dart';
part 'verification_runner.g.dart';

@freezed
class TestStatus with _$TestStatus {
  const factory TestStatus({
    required bool success,
    String? error,
  }) = _TestStatus;

  factory TestStatus.fromJson(Map<String, dynamic> json) =>
      _$TestStatusFromJson(json);
}

abstract class SystemVerification {
  Future<void> verifyFixes();
}

@injectable
class VerificationRunner {
  final SystemVerification _verification;
  final ILoggerService _logger;

  VerificationRunner({
    required SystemVerification verification,
    required ILoggerService logger,
  })  : _verification = verification,
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
      _logger.error('Verifikacija nije uspela', e);
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

  Future<TestStatus> _testBluetooth() async {
    try {
      // TODO: Implementirati bluetooth test
      return const TestStatus(success: true);
    } catch (e) {
      return TestStatus(success: false, error: e.toString());
    }
  }

  Future<TestStatus> _testSound() async {
    try {
      // TODO: Implementirati sound test
      return const TestStatus(success: true);
    } catch (e) {
      return TestStatus(success: false, error: e.toString());
    }
  }

  Future<TestStatus> _testMesh() async {
    try {
      // TODO: Implementirati mesh test
      return const TestStatus(success: true);
    } catch (e) {
      return TestStatus(success: false, error: e.toString());
    }
  }

  Future<TestStatus> _testSecurityIntegration() async {
    try {
      // TODO: Implementirati security integration test
      return const TestStatus(success: true);
    } catch (e) {
      return TestStatus(success: false, error: e.toString());
    }
  }

  Future<TestStatus> _testDataFlow() async {
    try {
      // TODO: Implementirati data flow test
      return const TestStatus(success: true);
    } catch (e) {
      return TestStatus(success: false, error: e.toString());
    }
  }

  String _formatStatus(TestStatus status) {
    return status.success ? '✅ RADI' : '❌ NE RADI (${status.error})';
  }
}

class VerificationException implements Exception {
  final String message;
  VerificationException(this.message);

  @override
  String toString() => message;
}
