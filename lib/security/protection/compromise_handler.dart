class CompromiseHandler {
  static final double REQUIRED_CONFIRMATION_RATIO =
      0.5; // 50% seedova mora da potvrdi
  final VirusProtection _virusProtection = VirusProtection();

  Future<void> handleCompromisedAdmin(String adminId) async {
    // 1. Obaveštavanje povezanih seedova
    await _notifyConnectedSeeds(adminId);

    // 2. Čekanje potvrda
    final confirmations = await _collectSeedConfirmations(adminId);
    final totalSeeds = await _getConnectedSeedsCount(adminId);

    if (_isCompromiseConfirmed(confirmations, totalSeeds)) {
      await _lockAdminDevice(adminId);
    }
  }

  Future<void> secretMasterOverride(String adminId) async {
    // Secret Master može da pokrene virus koji menja kod
    await _virusProtection.deployRecoveryVirus(adminId);
  }
}
