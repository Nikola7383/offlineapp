class MessageSecurity {
  final Encrypter encrypter;
  final IV iv;

  Future<String> encryptMessage(String message) async {
    final key = await generateKey();
    return encrypter.encrypt(message, key: key, iv: iv).base64;
  }

  Future<String> decryptMessage(String encrypted) async {
    final key = await getKey();
    return encrypter.decrypt64(encrypted, key: key, iv: iv);
  }
}
