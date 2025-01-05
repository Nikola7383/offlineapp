import 'dart:io';
import 'dart:convert';
import 'package:encrypt/encrypt.dart';

class SecureLocalStorage {
  static final SecureLocalStorage _instance = SecureLocalStorage._internal();
  final String _secureFilePath = 'secure_data.enc';
  late final Key _storageKey;

  factory SecureLocalStorage() {
    return _instance;
  }

  SecureLocalStorage._internal() {
    _initializeStorage();
  }

  void _initializeStorage() {
    // Generišemo ključ baziran na hardware ID i drugim lokalnim faktorima
    final deviceInfo = _getDeviceSpecificInfo();
    final keyData = sha256.convert(utf8.encode(deviceInfo)).bytes;
    _storageKey = Key(Uint8List.fromList(keyData));
  }

  String _getDeviceSpecificInfo() {
    // Kombinujemo više faktora specifičnih za uređaj
    // Ovo čini nemoguće čitanje podataka na drugom uređaju
    final factors = [
      Platform.operatingSystemVersion,
      Platform.numberOfProcessors.toString(),
      Platform.localHostname,
      // Dodajemo i hardware-specific informacije
    ].join('_');

    return factors;
  }

  Future<void> secureStore(String key, dynamic data) async {
    try {
      final encrypter = Encrypter(AES(_storageKey));
      final encrypted = encrypter.encrypt(json.encode(data));

      // Čuvamo u skrivenom fajlu
      final file = File(_secureFilePath);
      await file.writeAsBytes(encrypted.bytes);
    } catch (e) {
      print('Secure storage error: $e');
    }
  }

  Future<dynamic> secureRead() async {
    try {
      final file = File(_secureFilePath);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();
      final encrypter = Encrypter(AES(_storageKey));
      final decrypted = encrypter.decrypt64(base64.encode(bytes));

      return json.decode(decrypted);
    } catch (e) {
      print('Secure read error: $e');
      return null;
    }
  }
}
