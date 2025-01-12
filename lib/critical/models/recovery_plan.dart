import 'package:freezed_annotation/freezed_annotation.dart';
import 'base_model.dart';

part 'recovery_plan.freezed.dart';
part 'recovery_plan.g.dart';

enum RecoveryPriority { low, medium, high, critical, immediate }

@freezed
class RecoveryStep with _$RecoveryStep {
  const factory RecoveryStep({
    required String id,
    required String description,
    required int order,
    required bool isCompleted,
    String? error,
  }) = _RecoveryStep;

  factory RecoveryStep.fromJson(Map<String, dynamic> json) =>
      _$RecoveryStepFromJson(json);
}

@freezed
class RecoveryPlan with BaseModelMixin, _$RecoveryPlan {
  const factory RecoveryPlan({
    required String id,
    required DateTime timestamp,
    required List<RecoveryStep> steps,
    required RecoveryPriority priority,
    required Map<String, dynamic> metadata,
  }) = _RecoveryPlan;

  factory RecoveryPlan.fromJson(Map<String, dynamic> json) =>
      _$RecoveryPlanFromJson(json);
}
