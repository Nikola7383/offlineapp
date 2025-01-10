import 'package:freezed_annotation/freezed_annotation.dart';
import '../base/base_model.dart';

part 'broadcast_message.freezed.dart';
part 'broadcast_message.g.dart';

@freezed
class BroadcastMessage with _$BroadcastMessage implements BaseModel {
  const factory BroadcastMessage({
    required String id,
    required String content,
    required String senderId,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isUrgent,
    @Default(true) bool isActive,
    @Default([]) List<String> receivedByIds,
  }) = _BroadcastMessage;

  factory BroadcastMessage.fromJson(Map<String, dynamic> json) =>
      _$BroadcastMessageFromJson(json);

  const BroadcastMessage._();

  bool get isExpired => DateTime.now().difference(createdAt).inDays >= 7;

  BroadcastMessage markAsReceived(String userId) {
    if (receivedByIds.contains(userId)) return this;
    return copyWith(
      receivedByIds: [...receivedByIds, userId],
      updatedAt: DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toJson() => _$BroadcastMessageToJson(this);

  @override
  BaseModel fromJson(Map<String, dynamic> json) =>
      BroadcastMessage.fromJson(json);
}
