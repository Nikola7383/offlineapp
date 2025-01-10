// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'broadcast_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BroadcastMessage _$BroadcastMessageFromJson(Map<String, dynamic> json) {
  return _BroadcastMessage.fromJson(json);
}

/// @nodoc
mixin _$BroadcastMessage {
  String get id => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  bool get isUrgent => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  List<String> get receivedByIds => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BroadcastMessageCopyWith<BroadcastMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BroadcastMessageCopyWith<$Res> {
  factory $BroadcastMessageCopyWith(
          BroadcastMessage value, $Res Function(BroadcastMessage) then) =
      _$BroadcastMessageCopyWithImpl<$Res, BroadcastMessage>;
  @useResult
  $Res call(
      {String id,
      String content,
      String senderId,
      DateTime createdAt,
      DateTime updatedAt,
      bool isUrgent,
      bool isActive,
      List<String> receivedByIds});
}

/// @nodoc
class _$BroadcastMessageCopyWithImpl<$Res, $Val extends BroadcastMessage>
    implements $BroadcastMessageCopyWith<$Res> {
  _$BroadcastMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? content = null,
    Object? senderId = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? isUrgent = null,
    Object? isActive = null,
    Object? receivedByIds = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isUrgent: null == isUrgent
          ? _value.isUrgent
          : isUrgent // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      receivedByIds: null == receivedByIds
          ? _value.receivedByIds
          : receivedByIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BroadcastMessageImplCopyWith<$Res>
    implements $BroadcastMessageCopyWith<$Res> {
  factory _$$BroadcastMessageImplCopyWith(_$BroadcastMessageImpl value,
          $Res Function(_$BroadcastMessageImpl) then) =
      __$$BroadcastMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String content,
      String senderId,
      DateTime createdAt,
      DateTime updatedAt,
      bool isUrgent,
      bool isActive,
      List<String> receivedByIds});
}

/// @nodoc
class __$$BroadcastMessageImplCopyWithImpl<$Res>
    extends _$BroadcastMessageCopyWithImpl<$Res, _$BroadcastMessageImpl>
    implements _$$BroadcastMessageImplCopyWith<$Res> {
  __$$BroadcastMessageImplCopyWithImpl(_$BroadcastMessageImpl _value,
      $Res Function(_$BroadcastMessageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? content = null,
    Object? senderId = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? isUrgent = null,
    Object? isActive = null,
    Object? receivedByIds = null,
  }) {
    return _then(_$BroadcastMessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isUrgent: null == isUrgent
          ? _value.isUrgent
          : isUrgent // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      receivedByIds: null == receivedByIds
          ? _value._receivedByIds
          : receivedByIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BroadcastMessageImpl extends _BroadcastMessage {
  const _$BroadcastMessageImpl(
      {required this.id,
      required this.content,
      required this.senderId,
      required this.createdAt,
      required this.updatedAt,
      this.isUrgent = false,
      this.isActive = true,
      final List<String> receivedByIds = const []})
      : _receivedByIds = receivedByIds,
        super._();

  factory _$BroadcastMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$BroadcastMessageImplFromJson(json);

  @override
  final String id;
  @override
  final String content;
  @override
  final String senderId;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  @JsonKey()
  final bool isUrgent;
  @override
  @JsonKey()
  final bool isActive;
  final List<String> _receivedByIds;
  @override
  @JsonKey()
  List<String> get receivedByIds {
    if (_receivedByIds is EqualUnmodifiableListView) return _receivedByIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_receivedByIds);
  }

  @override
  String toString() {
    return 'BroadcastMessage(id: $id, content: $content, senderId: $senderId, createdAt: $createdAt, updatedAt: $updatedAt, isUrgent: $isUrgent, isActive: $isActive, receivedByIds: $receivedByIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BroadcastMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isUrgent, isUrgent) ||
                other.isUrgent == isUrgent) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            const DeepCollectionEquality()
                .equals(other._receivedByIds, _receivedByIds));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      content,
      senderId,
      createdAt,
      updatedAt,
      isUrgent,
      isActive,
      const DeepCollectionEquality().hash(_receivedByIds));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BroadcastMessageImplCopyWith<_$BroadcastMessageImpl> get copyWith =>
      __$$BroadcastMessageImplCopyWithImpl<_$BroadcastMessageImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BroadcastMessageImplToJson(
      this,
    );
  }
}

abstract class _BroadcastMessage extends BroadcastMessage {
  const factory _BroadcastMessage(
      {required final String id,
      required final String content,
      required final String senderId,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final bool isUrgent,
      final bool isActive,
      final List<String> receivedByIds}) = _$BroadcastMessageImpl;
  const _BroadcastMessage._() : super._();

  factory _BroadcastMessage.fromJson(Map<String, dynamic> json) =
      _$BroadcastMessageImpl.fromJson;

  @override
  String get id;
  @override
  String get content;
  @override
  String get senderId;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  bool get isUrgent;
  @override
  bool get isActive;
  @override
  List<String> get receivedByIds;
  @override
  @JsonKey(ignore: true)
  _$$BroadcastMessageImplCopyWith<_$BroadcastMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
