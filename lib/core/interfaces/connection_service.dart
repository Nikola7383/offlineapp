import '../models/connection_models.dart';

/// Interfejs za upravljanje konekcijama
abstract class IConnectionService extends IService {
  /// Stream statusa konekcije
  Stream<ConnectionStatus> get statusStream;

  /// Trenutni status konekcije
  ConnectionStatus get currentStatus;

  /// Dostupni tipovi konekcija
  Set<ConnectionType> get availableTypes;

  /// Proverava da li je tip konekcije dostupan
  Future<bool> isAvailable(ConnectionType type);

  /// Omogućava tip konekcije
  Future<Result<void>> enable(ConnectionType type);

  /// Onemogućava tip konekcije
  Future<Result<void>> disable(ConnectionType type);

  /// Forsira proveru statusa konekcije
  Future<Result<ConnectionStatus>> checkConnection();
}
