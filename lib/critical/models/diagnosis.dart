import 'package:freezed_annotation/freezed_annotation.dart';
import 'base_model.dart';
import 'critical_status.dart';

part 'diagnosis.freezed.dart';
part 'diagnosis.g.dart';

@freezed
class DiagnosisIssue with _$DiagnosisIssue {
  const factory DiagnosisIssue({
    required String id,
    required String description,
    required String severity,
    required bool isResolved,
    String? resolution,
  }) = _DiagnosisIssue;

  factory DiagnosisIssue.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisIssueFromJson(json);
}

@freezed
class Diagnosis with BaseModelMixin, _$Diagnosis {
  const factory Diagnosis({
    required String id,
    required DateTime timestamp,
    required List<DiagnosisIssue> issues,
    required SystemStatus status,
    required Map<String, dynamic> metrics,
  }) = _Diagnosis;

  factory Diagnosis.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisFromJson(json);
}
