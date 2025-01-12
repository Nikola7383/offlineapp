import 'base_service.dart';

/// Tip enkripcije
enum EncryptionType { aes256, rsa2048, chacha20 }

/// Interfejs za enkripciju podataka
abstract class IEncryptionService implements IService {
  /// Enkriptuje podatke
  Future<List<int>> encrypt(List<int> data,
      {EncryptionType type = EncryptionType.aes256,
      Map<String, dynamic>? options});

  /// Dekriptuje podatke
  Future<List<int>> decrypt(List<int> encryptedData,
      {EncryptionType type = EncryptionType.aes256,
      Map<String, dynamic>? options});

  /// Generiše par ključeva
  Future<Map<String, String>> generateKeyPair();

  /// Enkriptuje podatke sa javnim ključem
  Future<List<int>> encryptWithPublicKey(List<int> data, String publicKey);

  /// Dekriptuje podatke sa privatnim ključem
  Future<List<int>> decryptWithPrivateKey(
      List<int> encryptedData, String privateKey);

  /// Generiše hash vrednost
  Future<String> hash(List<int> data);

  /// Verifikuje hash vrednost
  Future<bool> verifyHash(List<int> data, String hash);

  /// Generiše sigurnu random vrednost
  Future<List<int>> generateSecureRandom(int length);

  /// Proverava jačinu ključa
  Future<bool> validateKeyStrength(String key, EncryptionType type);
}
