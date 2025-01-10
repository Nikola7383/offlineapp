import 'package:freezed_annotation/freezed_annotation.dart';

abstract class BaseModel {
  String get id;
  DateTime get createdAt;
  DateTime get updatedAt;
  bool get isActive;

  Map<String, dynamic> toJson();
  BaseModel fromJson(Map<String, dynamic> json);
}

abstract class BaseSecureModel extends BaseModel {
  String get encryptionKey;
  String get encryptionIv;
  bool get isEncrypted;
}

abstract class BaseOfflineModel extends BaseModel {
  bool get isSynced;
  DateTime? get lastSyncAt;
  int get version;
}

abstract class BaseEventModel extends BaseModel {
  String get eventId;
  DateTime get eventDate;
  String get createdBy;
  bool get isProcessed;
}
