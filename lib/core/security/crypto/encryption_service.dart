class EncryptionService {
  static const int KEY_SIZE = 256;
  static const String ALGORITHM = 'AES-GCM';

  final SecureStorage _secureStorage;
  final KeyGenerator _keyGen;

  EncryptionService({
    required SecureStorage secureStorage,
    required KeyGenerator keyGen,
  })  : _secureStorage = secureStorage,
        _keyGen = keyGen;

  Future<void> initialize() async {
    try {
      // Proveri postojeće ključeve
      final hasKeys = await _secureStorage.hasKeys();

      if (!hasKeys) {
        // Generiši nove ključeve
        final masterKey = await _keyGen.generateMasterKey(KEY_SIZE);
        final derivationKey = await _keyGen.generateDerivationKey();

        // Sačuvaj ključeve
        await _secureStorage.storeMasterKey(masterKey);
        await _secureStorage.storeDerivationKey(derivationKey);
      }

      // Verifikuj ključeve
      await _verifyKeys();
    } catch (e) {
      throw EncryptionException('Failed to initialize encryption: $e');
    }
  }

  Future<String> encrypt(String data) async {
    try {
      final key = await _secureStorage.getMasterKey();
      final iv = _generateIV();

      final encrypted = await _encryptWithKey(data, key, iv);
      return base64.encode(encrypted);
    } catch (e) {
      throw EncryptionException('Encryption failed: $e');
    }
  }

  Future<String> decrypt(String encryptedData) async {
    try {
      final key = await _secureStorage.getMasterKey();
      final data = base64.decode(encryptedData);

      return await _decryptWithKey(data, key);
    } catch (e) {
      throw EncryptionException('Decryption failed: $e');
    }
  }
}
