// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'broadcast_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BroadcastMessageImpl _$$BroadcastMessageImplFromJson(
        Map<String, dynamic> json) =>
    _$BroadcastMessageImpl(
      id: json['id'] as String,
      content: json['content'] as String,
      senderId: json['senderId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isUrgent: json['isUrgent'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      receivedByIds: (json['receivedByIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$BroadcastMessageImplToJson(
        _$BroadcastMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'senderId': instance.senderId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isUrgent': instance.isUrgent,
      'isActive': instance.isActive,
      'receivedByIds': instance.receivedByIds,
    };
