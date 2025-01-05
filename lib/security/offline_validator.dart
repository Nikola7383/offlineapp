class OfflineValidator {
  static bool validateCompleteOffline() {
    return [
      _checkInternetPermissions(), // Nema internet dozvola u manifestu
      _checkNetworkCalls(), // Nema network poziva
      _checkExternalConnections(), // Nema eksternih konekcija
      _checkBackgroundServices(), // Nema background servisa
      _checkLibraryDependencies(), // Sve biblioteke rade offline
    ].every((check) => check == true);
  }
}
