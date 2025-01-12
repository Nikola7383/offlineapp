import 'base_service.dart';

/// Interfejs za upravljanje bazom podataka
abstract class IDatabaseService implements IService {
  /// Povezuje se sa bazom podataka
  Future<void> connect();

  /// Prekida vezu sa bazom podataka
  Future<void> disconnect();

  /// Proverava da li je veza sa bazom podataka aktivna
  bool get isConnected;

  /// Pravi backup baze podataka
  Future<void> backup();

  /// Vraća bazu podataka iz backup-a
  Future<void> restore();
}
