import 'package:freezed_annotation/freezed_annotation.dart';

part 'test_operation.freezed.dart';
part 'test_operation.g.dart';

@freezed
class TestOperation with _$TestOperation {
  const factory TestOperation(String name) = _TestOperation;

  factory TestOperation.fromJson(Map<String, dynamic> json) =>
      _$TestOperationFromJson(json);
}
