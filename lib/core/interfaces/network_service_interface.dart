import 'base_service.dart';

/// Status mrežne konekcije
enum NetworkStatus { connected, disconnected, connecting, error }

/// Tip mrežne konekcije
enum NetworkType { wifi, cellular, ethernet, bluetooth, none }

/// Interfejs za mrežnu komunikaciju
abstract class INetworkService implements IService {
  /// Trenutni status mreže
  NetworkStatus get status;

  /// Trenutni tip mreže
  NetworkType get type;

  /// Stream za praćenje promene statusa
  Stream<NetworkStatus> get onStatusChanged;

  /// Stream za praćenje promene tipa konekcije
  Stream<NetworkType> get onTypeChanged;

  /// Proverava da li je mreža dostupna
  Future<bool> checkConnectivity();

  /// Vraća trenutnu IP adresu
  Future<String?> getCurrentIpAddress();

  /// Vraća trenutnu jačinu signala (0-100)
  Future<int> getSignalStrength();

  /// Vraća trenutnu brzinu prenosa (bytes/s)
  Future<int> getTransferSpeed();

  /// Vraća listu dostupnih mreža
  Future<List<String>> getAvailableNetworks();

  /// Povezuje se na mrežu
  Future<void> connect(String networkId, {Map<String, dynamic>? options});

  /// Prekida konekciju
  Future<void> disconnect();

  /// Proverava dostupnost servera
  Future<bool> pingServer(String host);

  /// Vraća statistiku mrežnog saobraćaja
  Future<Map<String, int>> getTrafficStats();
}
