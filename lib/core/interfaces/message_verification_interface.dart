import '../models/encrypted_message.dart';
import '../models/verification_result.dart';
import 'base_service.dart';

/// Interfejs za servis za verifikaciju poruka
abstract class IMessageVerificationService implements IService {
  /// Verifikuje poruku
  Future<VerificationResult> verifyMessage(EncryptedMessage message);
}
