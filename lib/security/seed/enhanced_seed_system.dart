import 'dart:convert';
import 'package:crypto/crypto.dart';

class EnhancedSeedSystem {
  static final EnhancedSeedSystem _instance = EnhancedSeedSystem._internal();
  final Map<String, SeedToken> _activeTokens = {};
  final int _maxActivationAttempts = 3;

  factory EnhancedSeedSystem() {
    return _instance;
  }

  EnhancedSeedSystem._internal();

  Future<SeedToken> generateSecureToken(
      String deviceId, DateTime eventDate) async {
    final deviceIdentifier = await _getSecureDeviceIdentifier(deviceId);
    final token = SeedToken(
        tokenId: _generateTokenId(),
        deviceId: deviceId,
        deviceHash: deviceIdentifier,
        validFrom: eventDate,
        validUntil: eventDate.add(Duration(hours: 48)),
        activationAttempts: 0);

    _activeTokens[token.tokenId] = token;
    return token;
  }

  Future<bool> activateToken(String tokenId, String deviceId) async {
    final token = _activeTokens[tokenId];
    if (token == null) return false;

    if (token.activationAttempts >= _maxActivationAttempts) {
      _activeTokens.remove(tokenId);
      return false;
    }

    token.activationAttempts++;

    final currentDeviceHash = await _getSecureDeviceIdentifier(deviceId);
    if (token.deviceHash != currentDeviceHash) {
      return false;
    }

    final now = DateTime.now();
    if (now.isBefore(token.validFrom) || now.isAfter(token.validUntil)) {
      return false;
    }

    return true;
  }

  Future<String> _getSecureDeviceIdentifier(String deviceId) async {
    // Kombinacija hardware identifikatora
    return 'secure_device_hash';
  }

  String _generateTokenId() {
    // Generisanje sigurnog token ID-a
    return 'token_${DateTime.now().millisecondsSinceEpoch}';
  }
}

class SeedToken {
  final String tokenId;
  final String deviceId;
  final String deviceHash;
  final DateTime validFrom;
  final DateTime validUntil;
  int activationAttempts;

  SeedToken(
      {required this.tokenId,
      required this.deviceId,
      required this.deviceHash,
      required this.validFrom,
      required this.validUntil,
      required this.activationAttempts});
}
