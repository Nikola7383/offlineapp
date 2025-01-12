import 'package:freezed_annotation/freezed_annotation.dart';

part 'simulated_user.freezed.dart';
part 'simulated_user.g.dart';

@freezed
class SimulatedUser with _$SimulatedUser {
  const factory SimulatedUser({
    @Default('') String id,
    @Default('') String name,
    @Default(false) bool isActive,
  }) = _SimulatedUser;

  factory SimulatedUser.fromJson(Map<String, dynamic> json) =>
      _$SimulatedUserFromJson(json);
}

extension SimulatedUserExtension on SimulatedUser {
  Future<SimulationResult> simulateActivity({
    required Duration duration,
    required int messagesPerSecond,
  }) async {
    // TODO: Implementirati simulaciju aktivnosti
    return SimulationResult(isSuccessful: true);
  }
}

@freezed
class SimulationResult with _$SimulationResult {
  const factory SimulationResult({
    @Default(false) bool isSuccessful,
    String? error,
  }) = _SimulationResult;

  factory SimulationResult.fromJson(Map<String, dynamic> json) =>
      _$SimulationResultFromJson(json);
}
