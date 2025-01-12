import 'package:freezed_annotation/freezed_annotation.dart';

@immutable
abstract class BaseModel {
  const BaseModel();

  Map<String, dynamic> toJson();
}
