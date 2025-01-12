import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';
part 'result.g.dart';

/// Generic klasa za rezultate operacija
@freezed
class Result<T> with _$Result<T> {
  const factory Result.success(T? data) = Success<T>;
  const factory Result.failure(String message) = Failure<T>;
  const factory Result.loading() = Loading<T>;
}
