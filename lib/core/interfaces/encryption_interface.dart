import 'base_service.dart';
import '../../models/encryption_types.dart';

/// Interfejs za upravljanje enkripcijom
abstract class IEncryptionManager implements IService {
  /// Enkriptuje podatke
  Future<EncryptedData> encrypt(List<int> data, EncryptionConfig config);

  /// Dekriptuje podatke
  Future<List<int>> decrypt(EncryptedData data);

  /// Generiše par ključeva
  Future<KeyPair> generateKeyPair();

  /// Rotira ključeve
  Future<void> rotateKeys();

  /// Verifikuje integritet podataka
  Future<bool> verifyIntegrity(EncryptedData data);

  /// Upravlja ključevima
  Future<void> manageKeys(KeyOperation operation);

  /// Generiše izveštaj o enkripciji
  Future<EncryptionReport> generateReport();

  /// Konfiguriše parametre enkripcije
  Future<void> configure(EncryptionConfig config);

  /// Proverava status enkripcije
  Future<EncryptionStatus> checkStatus();

  /// Stream za praćenje događaja enkripcije
  Stream<EncryptionEvent> get encryptionEvents;

  /// Stream za praćenje statusa ključeva
  Stream<KeyStatus> get keyStatus;
}
