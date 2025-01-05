class SecretMaster {
  final KeyManager keyManager;

  SecretMaster({required this.keyManager}) {
    if (!keyManager.isInitialized) {
      throw Exception('KeyManager must be initialized');
    }
  }

  Future<String> encryptData(String data) async {
    final masterKey = keyManager.getMasterKey();
    // Jednostavna XOR enkripcija za demo
    return _xorEncrypt(data, masterKey);
  }

  Future<String> decryptData(String encryptedData) async {
    final masterKey = keyManager.getMasterKey();
    // XOR enkripcija je reverzibilna
    return _xorEncrypt(encryptedData, masterKey);
  }

  String _xorEncrypt(String data, String key) {
    final List<int> encrypted = [];
    for (var i = 0; i < data.length; i++) {
      encrypted.add(data.codeUnitAt(i) ^ key.codeUnitAt(i % key.length));
    }
    return String.fromCharCodes(encrypted);
  }
}
