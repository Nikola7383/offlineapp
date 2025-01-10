import 'package:freezed_annotation/freezed_annotation.dart';
import '../base/base_model.dart';

part 'guest_user.freezed.dart';
part 'guest_user.g.dart';

@freezed
class GuestUser with _$GuestUser implements BaseModel {
  const factory GuestUser({
    required String id,
    required String deviceId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime expiresAt,
    @Default(false) bool isActive,
    @Default([]) List<String> receivedBroadcastIds,
  }) = _GuestUser;

  factory GuestUser.fromJson(Map<String, dynamic> json) =>
      _$GuestUserFromJson(json);

  const GuestUser._();

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get canReceiveBroadcasts => isActive && !isExpired;

  GuestUser copyWithReceived(String broadcastId) {
    return copyWith(
      receivedBroadcastIds: [...receivedBroadcastIds, broadcastId],
      updatedAt: DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toJson() => _$GuestUserToJson(this);

  @override
  BaseModel fromJson(Map<String, dynamic> json) => GuestUser.fromJson(json);
}
