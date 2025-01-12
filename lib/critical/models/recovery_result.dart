import 'package:freezed_annotation/freezed_annotation.dart';
import 'base_model.dart';

part 'recovery_result.freezed.dart';
part 'recovery_result.g.dart';

@freezed
class RecoveryResult with BaseModelMixin, _$RecoveryResult {
  const factory RecoveryResult({
    required String id,
    required DateTime timestamp,
    required bool success,
    required String message,
    required Map<String, dynamic> metrics,
    List<String>? warnings,
    List<String>? errors,
  }) = _RecoveryResult;

  factory RecoveryResult.fromJson(Map<String, dynamic> json) =>
      _$RecoveryResultFromJson(json);
}
