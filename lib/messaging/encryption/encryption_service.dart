import 'dart:convert';
import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/digests/sha256.dart';
import '../../core/interfaces/base_service.dart';

/// Servis za enkripciju
@LazySingleton()
class EncryptionService implements IService {
  final _cipher = AsymmetricBlockCipher('RSA');
  final _digest = SHA256Digest();

  @override
  Future<void> initialize() async {
    // Nema potrebe za inicijalizacijom
  }

  @override
  Future<void> dispose() async {
    // Nema potrebe za čišćenjem resursa
  }

  /// Enkriptuje string u base64 enkodiran string
  Future<String> encrypt(String data, RSAPublicKey publicKey) async {
    try {
      final params = PublicKeyParameter<RSAPublicKey>(publicKey);
      _cipher.init(true, params);

      final input = Uint8List.fromList(utf8.encode(data));
      final output = _cipher.process(input);

      return base64.encode(output);
    } catch (e) {
      throw Exception('Greška prilikom enkripcije: $e');
    }
  }

  /// Dekriptuje base64 enkodiran string u običan string
  Future<String> decrypt(String encodedData, RSAPrivateKey privateKey) async {
    try {
      final params = PrivateKeyParameter<RSAPrivateKey>(privateKey);
      _cipher.init(false, params);

      final input = base64.decode(encodedData);
      final output = _cipher.process(Uint8List.fromList(input));

      return utf8.decode(output);
    } catch (e) {
      throw Exception('Greška prilikom dekripcije: $e');
    }
  }

  /// Kreira potpis za podatke
  Future<Uint8List> sign(String data, RSAPrivateKey privateKey) async {
    try {
      final params = PrivateKeyParameter<RSAPrivateKey>(privateKey);
      _cipher.init(true, params);

      final hash = calculateHash(data);
      final input = Uint8List.fromList(utf8.encode(hash));
      return _cipher.process(input);
    } catch (e) {
      throw Exception('Greška prilikom kreiranja potpisa: $e');
    }
  }

  /// Verifikuje potpis
  Future<bool> verifySignature(
    String data,
    Uint8List signature,
    RSAPublicKey publicKey,
  ) async {
    try {
      final params = PublicKeyParameter<RSAPublicKey>(publicKey);
      _cipher.init(false, params);

      final hash = calculateHash(data);
      final decryptedSignature = utf8.decode(_cipher.process(signature));

      return hash == decryptedSignature;
    } catch (e) {
      throw Exception('Greška prilikom verifikacije potpisa: $e');
    }
  }

  /// Računa hash za podatke
  String calculateHash(String data) {
    final bytes = utf8.encode(data);
    final hash = _digest.process(Uint8List.fromList(bytes));
    return base64.encode(hash);
  }
}
