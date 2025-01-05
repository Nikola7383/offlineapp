class SecurityController {
  final EnhancedProximityValidator _proximityValidator =
      EnhancedProximityValidator();
  final EnhancedSeedSystem _seedSystem = EnhancedSeedSystem();
  final AntiTampering _antiTampering = AntiTampering();
  final SecureAuditLog _auditLog = SecureAuditLog();
  final AdminLimitControl _adminControl = AdminLimitControl();

  Future<bool> validateSecurityState() async {
    // Provera svih sigurnosnih sistema
    final deviceIntegrity = await _antiTampering.validateDeviceIntegrity();
    if (!deviceIntegrity) {
      _auditLog.logSecurityEvent('INTEGRITY_CHECK_FAILED',
          {'timestamp': DateTime.now().toIso8601String()});
      return false;
    }

    return true;
  }

  Future<bool> processSeedActivation(String tokenId, String deviceId) async {
    if (!await validateSecurityState()) return false;

    final proximityValid =
        await _proximityValidator.validateMultiFactorProximity(deviceId);
    if (!proximityValid) {
      _auditLog.logSecurityEvent(
          'PROXIMITY_CHECK_FAILED', {'deviceId': deviceId, 'tokenId': tokenId});
      return false;
    }

    final tokenValid = await _seedSystem.activateToken(tokenId, deviceId);
    _auditLog.logSecurityEvent('SEED_ACTIVATION_ATTEMPT',
        {'deviceId': deviceId, 'tokenId': tokenId, 'success': tokenValid});

    return tokenValid;
  }
}
