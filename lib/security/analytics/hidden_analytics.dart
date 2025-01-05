class HiddenAnalytics {
  static final HiddenAnalytics _instance = HiddenAnalytics._internal();
  bool _isAnalyticsEnabled = false;
  final List<Map<String, dynamic>> _securityEvents = [];

  factory HiddenAnalytics() {
    return _instance;
  }

  HiddenAnalytics._internal();

  void enableAnalytics(String secretCode) {
    // Aktivira se samo sa posebnim kodom koji znaju administratori
    if (_validateSecretCode(secretCode)) {
      _isAnalyticsEnabled = true;
    }
  }

  void logSecurityEvent(String eventType, Map<String, dynamic> details) {
    if (!_isAnalyticsEnabled) return; // Ne loguje ništa ako nije aktivirano

    _securityEvents.add({
      'timestamp': DateTime.now().toIso8601String(),
      'type': eventType,
      'details': details
    });
  }

  List<Map<String, dynamic>> exportAnalytics(String adminCode) {
    if (!_validateAdminCode(adminCode)) return [];

    final data = List<Map<String, dynamic>>.from(_securityEvents);
    _securityEvents.clear(); // Čistimo nakon izvoza
    return data;
  }

  bool _validateSecretCode(String code) {
    // Kompleksna validacija koda
    return code == "your_secret_code"; // Ovo treba da bude mnogo kompleksnije
  }

  bool _validateAdminCode(String code) {
    // Dodatna validacija za admin pristup
    return code == "your_admin_code"; // Ovo treba da bude mnogo kompleksnije
  }
}
