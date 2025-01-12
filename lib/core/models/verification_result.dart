import 'package:freezed_annotation/freezed_annotation.dart';
import 'encrypted_message.dart';

part 'verification_result.freezed.dart';

/// Model koji predstavlja rezultat verifikacije poruke
@freezed
class VerificationResult with _$VerificationResult {
  const factory VerificationResult({
    required bool isValid,
    required EncryptedMessage message,
    required DateTime verificationTime,
    String? failureReason,
    Map<String, dynamic>? details,
  }) = _VerificationResult;
}
