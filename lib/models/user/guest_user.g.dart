// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GuestUserImpl _$$GuestUserImplFromJson(Map<String, dynamic> json) =>
    _$GuestUserImpl(
      id: json['id'] as String,
      deviceId: json['deviceId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      isActive: json['isActive'] as bool? ?? false,
      receivedBroadcastIds: (json['receivedBroadcastIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$GuestUserImplToJson(_$GuestUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deviceId': instance.deviceId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'isActive': instance.isActive,
      'receivedBroadcastIds': instance.receivedBroadcastIds,
    };
