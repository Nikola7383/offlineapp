import 'package:freezed_annotation/freezed_annotation.dart';

abstract class BaseModel {
  String get id;
  DateTime get timestamp;

  Map<String, dynamic> toJson();
}

mixin BaseModelMixin implements BaseModel {
  @override
  String get id;

  @override
  DateTime get timestamp;
}
