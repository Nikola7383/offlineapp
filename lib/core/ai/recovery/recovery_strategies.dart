import 'package:freezed_annotation/freezed_annotation.dart';

part 'recovery_strategies.freezed.dart';
part 'recovery_strategies.g.dart';

@freezed
class RecoveryStrategy with _$RecoveryStrategy {
  const factory RecoveryStrategy({
    required String name,
    required String description,
    @Default([]) List<String> steps,
    @Default({}) Map<String, dynamic> parameters,
  }) = _RecoveryStrategy;

  factory RecoveryStrategy.fromJson(Map<String, dynamic> json) =>
      _$RecoveryStrategyFromJson(json);
}

class RecoveryStrategyManager {
  Future<RecoveryStrategy> selectStrategy(String issue) async {
    // TODO: Implementirati logiku za izbor strategije oporavka
    return const RecoveryStrategy(
      name: 'default',
      description: 'Default recovery strategy',
    );
  }
}
