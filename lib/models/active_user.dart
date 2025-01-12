import 'package:freezed_annotation/freezed_annotation.dart';

part 'active_user.freezed.dart';
part 'active_user.g.dart';

@freezed
class ActiveUser with _$ActiveUser {
  const factory ActiveUser({
    required String id,
    required String username,
    required String role,
    required DateTime lastActive,
    required bool isOnline,
    String? deviceId,
    String? lastKnownLocation,
  }) = _ActiveUser;

  factory ActiveUser.fromJson(Map<String, dynamic> json) =>
      _$ActiveUserFromJson(json);
}
