class MasterAdmin {
  final KeyManager keyManager;
  static const String _validUsername = 'admin';
  static const String _validPassword = 'masterpass123';

  MasterAdmin({required this.keyManager}) {
    if (!keyManager.isInitialized) {
      throw Exception('KeyManager must be initialized');
    }
  }

  Future<bool> verifyCredentials({
    required String username,
    required String password,
  }) async {
    // Proveravamo prvo master ključ
    final masterKey = keyManager.getMasterKey();
    if (masterKey.isEmpty) return false;

    // Zatim proveravamo kredencijale
    return username == _validUsername && password == _validPassword;
  }
}
