import 'package:freezed_annotation/freezed_annotation.dart';

part 'test_model.freezed.dart';
part 'test_model.g.dart';

@freezed
@JsonSerializable()
class TestModel with _$TestModel {
  const factory TestModel({
    required String id,
    required String name,
    @Default(false) bool isActive,
  }) = _TestModel;

  factory TestModel.fromJson(Map<String, dynamic> json) =>
      _$TestModelFromJson(json);
}
