import 'package:freezed_annotation/freezed_annotation.dart';

part 'verification_state.freezed.dart';
part 'verification_state.g.dart';

@freezed
class VerificationState with _$VerificationState {
  const factory VerificationState({
    @Default(false) bool isLoading,
    @Default(false) bool isVerified,
    @Default(false) bool isOffline,
    String? error,
    DateTime? lastVerificationTime,
  }) = _VerificationState;

  factory VerificationState.fromJson(Map<String, dynamic> json) =>
      _$VerificationStateFromJson(json);
}
