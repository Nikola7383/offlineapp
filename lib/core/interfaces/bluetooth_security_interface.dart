import 'base_service.dart';
import '../../models/bluetooth_security_types.dart';

/// Interfejs za upravljanje Bluetooth bezbednošću
abstract class IBluetoothSecurityManager implements IService {
  /// Skenira dostupne Bluetooth uređaje
  Future<List<BluetoothDevice>> scanDevices();

  /// Proverava bezbednost Bluetooth veze
  Future<BluetoothSecurityStatus> checkConnectionSecurity(String deviceId);

  /// Uspostavlja sigurnu vezu sa uređajem
  Future<BluetoothConnection> establishSecureConnection(String deviceId);

  /// Prekida vezu sa uređajem
  Future<void> disconnectDevice(String deviceId);

  /// Verifikuje identitet uređaja
  Future<bool> verifyDeviceIdentity(String deviceId);

  /// Upravlja bezbednosnim ključevima
  Future<void> manageSecurityKeys(String deviceId);

  /// Generiše bezbednosni izveštaj
  Future<BluetoothSecurityReport> generateSecurityReport();

  /// Konfiguriše bezbednosne parametre
  Future<void> configureSecurityParameters(BluetoothSecurityConfig config);

  /// Detektuje potencijalne pretnje
  Future<List<BluetoothThreat>> detectThreats();

  /// Primenjuje bezbednosne politike
  Future<void> enforceSecurityPolicies(List<BluetoothSecurityPolicy> policies);

  /// Stream za praćenje bezbednosnih događaja
  Stream<BluetoothSecurityEvent> get securityEvents;

  /// Stream za praćenje statusa veze
  Stream<BluetoothConnectionStatus> get connectionStatus;
}
