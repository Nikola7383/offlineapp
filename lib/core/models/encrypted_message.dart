import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:typed_data';

part 'encrypted_message.freezed.dart';
part 'encrypted_message.g.dart';

/// Konverter za Uint8List
class Uint8ListConverter implements JsonConverter<Uint8List, List<int>> {
  const Uint8ListConverter();

  @override
  Uint8List fromJson(List<int> json) => Uint8List.fromList(json);

  @override
  List<int> toJson(Uint8List object) => object.toList();
}

/// Model koji predstavlja enkriptovanu poruku
@freezed
class EncryptedMessage with _$EncryptedMessage {
  const factory EncryptedMessage({
    required String id,
    required String senderId,
    required String recipientId,
    required String content,
    required String hash,
    @Uint8ListConverter() required Uint8List signature,
    required DateTime timestamp,
    required String type,
    required int priority,
  }) = _EncryptedMessage;

  factory EncryptedMessage.fromJson(Map<String, dynamic> json) =>
      _$EncryptedMessageFromJson(json);
}
