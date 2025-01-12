import '../../core/interfaces/base_service.dart';

/// Interfejs za verifikaciju poruka
abstract class IMessageVerificationService implements IService {
  /// Verifikuje integritet poruke
  Future<bool> verifyMessageIntegrity(String messageId, String hash);

  /// Verifikuje potpis poruke
  Future<bool> verifyMessageSignature(String messageId, String signature);

  /// Verifikuje vremensku oznaku poruke
  Future<bool> verifyMessageTimestamp(String messageId, DateTime timestamp);

  /// Verifikuje poreklo poruke
  Future<bool> verifyMessageOrigin(String messageId, String senderId);
}
