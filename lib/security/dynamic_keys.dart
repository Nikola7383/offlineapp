import 'dart:async';
import 'dart:math';
import 'dart:convert';

class DynamicKeyManager {
  late Timer _primaryKeyTimer;
  late Timer _backupKeyTimer;
  final _keyLength = 256;

  String _currentPrimaryKey;
  String _currentBackupKey;

  DynamicKeyManager() {
    _currentPrimaryKey = _generateNewKey();
    _currentBackupKey = _generateNewKey();
    _startKeyRotation();
  }

  String _generateNewKey() {
    final random = Random.secure();
    final values =
        List<int>.generate(_keyLength ~/ 8, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  void _startKeyRotation() {
    _primaryKeyTimer = Timer.periodic(Duration(minutes: 15), (_) {
      _currentPrimaryKey = _generateNewKey();
      _notifyKeyChange(isPrimary: true);
    });

    _backupKeyTimer = Timer.periodic(Duration(hours: 1), (_) {
      _currentBackupKey = _generateNewKey();
      _notifyKeyChange(isPrimary: false);
    });
  }

  void _notifyKeyChange({required bool isPrimary}) {
    print('Ključ je promenjen: ${isPrimary ? 'primarni' : 'backup'}');
  }

  void dispose() {
    _primaryKeyTimer.cancel();
    _backupKeyTimer.cancel();
  }
}
