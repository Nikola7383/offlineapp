// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'guest_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GuestUser _$GuestUserFromJson(Map<String, dynamic> json) {
  return _GuestUser.fromJson(json);
}

/// @nodoc
mixin _$GuestUser {
  String get id => throw _privateConstructorUsedError;
  String get deviceId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime get expiresAt => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  List<String> get receivedBroadcastIds => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GuestUserCopyWith<GuestUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GuestUserCopyWith<$Res> {
  factory $GuestUserCopyWith(GuestUser value, $Res Function(GuestUser) then) =
      _$GuestUserCopyWithImpl<$Res, GuestUser>;
  @useResult
  $Res call(
      {String id,
      String deviceId,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime expiresAt,
      bool isActive,
      List<String> receivedBroadcastIds});
}

/// @nodoc
class _$GuestUserCopyWithImpl<$Res, $Val extends GuestUser>
    implements $GuestUserCopyWith<$Res> {
  _$GuestUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deviceId = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? expiresAt = null,
    Object? isActive = null,
    Object? receivedBroadcastIds = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      receivedBroadcastIds: null == receivedBroadcastIds
          ? _value.receivedBroadcastIds
          : receivedBroadcastIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GuestUserImplCopyWith<$Res>
    implements $GuestUserCopyWith<$Res> {
  factory _$$GuestUserImplCopyWith(
          _$GuestUserImpl value, $Res Function(_$GuestUserImpl) then) =
      __$$GuestUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String deviceId,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime expiresAt,
      bool isActive,
      List<String> receivedBroadcastIds});
}

/// @nodoc
class __$$GuestUserImplCopyWithImpl<$Res>
    extends _$GuestUserCopyWithImpl<$Res, _$GuestUserImpl>
    implements _$$GuestUserImplCopyWith<$Res> {
  __$$GuestUserImplCopyWithImpl(
      _$GuestUserImpl _value, $Res Function(_$GuestUserImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deviceId = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? expiresAt = null,
    Object? isActive = null,
    Object? receivedBroadcastIds = null,
  }) {
    return _then(_$GuestUserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      receivedBroadcastIds: null == receivedBroadcastIds
          ? _value._receivedBroadcastIds
          : receivedBroadcastIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GuestUserImpl extends _GuestUser {
  const _$GuestUserImpl(
      {required this.id,
      required this.deviceId,
      required this.createdAt,
      required this.updatedAt,
      required this.expiresAt,
      this.isActive = false,
      final List<String> receivedBroadcastIds = const []})
      : _receivedBroadcastIds = receivedBroadcastIds,
        super._();

  factory _$GuestUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$GuestUserImplFromJson(json);

  @override
  final String id;
  @override
  final String deviceId;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime expiresAt;
  @override
  @JsonKey()
  final bool isActive;
  final List<String> _receivedBroadcastIds;
  @override
  @JsonKey()
  List<String> get receivedBroadcastIds {
    if (_receivedBroadcastIds is EqualUnmodifiableListView)
      return _receivedBroadcastIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_receivedBroadcastIds);
  }

  @override
  String toString() {
    return 'GuestUser(id: $id, deviceId: $deviceId, createdAt: $createdAt, updatedAt: $updatedAt, expiresAt: $expiresAt, isActive: $isActive, receivedBroadcastIds: $receivedBroadcastIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GuestUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            const DeepCollectionEquality()
                .equals(other._receivedBroadcastIds, _receivedBroadcastIds));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      deviceId,
      createdAt,
      updatedAt,
      expiresAt,
      isActive,
      const DeepCollectionEquality().hash(_receivedBroadcastIds));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GuestUserImplCopyWith<_$GuestUserImpl> get copyWith =>
      __$$GuestUserImplCopyWithImpl<_$GuestUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GuestUserImplToJson(
      this,
    );
  }
}

abstract class _GuestUser extends GuestUser {
  const factory _GuestUser(
      {required final String id,
      required final String deviceId,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final DateTime expiresAt,
      final bool isActive,
      final List<String> receivedBroadcastIds}) = _$GuestUserImpl;
  const _GuestUser._() : super._();

  factory _GuestUser.fromJson(Map<String, dynamic> json) =
      _$GuestUserImpl.fromJson;

  @override
  String get id;
  @override
  String get deviceId;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime get expiresAt;
  @override
  bool get isActive;
  @override
  List<String> get receivedBroadcastIds;
  @override
  @JsonKey(ignore: true)
  _$$GuestUserImplCopyWith<_$GuestUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
