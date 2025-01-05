class DeadMansSwitchCore {
  static final DeadMansSwitchCore _instance = DeadMansSwitchCore._internal();
  final Duration _checkInterval = Duration(hours: 24);
  final int _maxMissedChecks = 3;
  Timer? _checkTimer;
  int _missedChecks = 0;
  final String _activationPhrase = "Sve je u redu, samo rutinska provera";

  factory DeadMansSwitchCore() {
    return _instance;
  }

  DeadMansSwitchCore._internal() {
    _initializeSwitch();
  }

  void _initializeSwitch() {
    _checkTimer = Timer.periodic(_checkInterval, (timer) {
      _performCheck();
    });
  }

  Future<void> _performCheck() async {
    _missedChecks++;

    if (_missedChecks >= _maxMissedChecks) {
      await _activateDeadMansProtocol();
    }
  }

  Future<void> checkIn(String phrase) async {
    if (phrase == _activationPhrase) {
      _missedChecks = 0;
    } else {
      // Pogrešna fraza aktivira protokol odmah
      await _activateDeadMansProtocol();
    }
  }

  Future<void> _activateDeadMansProtocol() async {
    try {
      // 1. Sigurno brisanje podataka
      await _secureWipe();

      // 2. Aktiviranje Phoenix sistema
      await PhoenixCore().initiateRecovery();

      // 3. Notifikacija trusted uređaja
      await _notifyTrustedDevices();

      // 4. Deployment deception mehanizama
      await _deployDeceptionMechanisms();
    } catch (e) {
      // Silent fail - ne želimo da pokažemo da je nešto pošlo po zlu
    }
  }

  Future<void> _secureWipe() async {
    // Implementacija sigurnog brisanja
  }

  Future<void> _notifyTrustedDevices() async {
    // Implementacija notifikacije
  }

  Future<void> _deployDeceptionMechanisms() async {
    // Implementacija deception mehanizama
  }

  void dispose() {
    _checkTimer?.cancel();
  }
}
