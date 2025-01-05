class BiometricValidator {
  static final BiometricValidator _instance = BiometricValidator._internal();

  Future<bool> validateCriticalOperation(
      String adminId, CriticalOperationType operationType) async {
    // Zahtevamo biometriju za:
    switch (operationType) {
      case CriticalOperationType.massBroadcast:
        return await _validateBiometrics(SecurityLevel.high);
      case CriticalOperationType.systemRecovery:
        return await _validateBiometrics(SecurityLevel.maximum);
      case CriticalOperationType.seedManagement:
        return await _validateBiometrics(SecurityLevel.medium);
      default:
        return await _validateBiometrics(SecurityLevel.standard);
    }
  }
}

enum CriticalOperationType {
  massBroadcast,
  systemRecovery,
  seedManagement,
  configurationChange
}

enum SecurityLevel { standard, medium, high, maximum }
