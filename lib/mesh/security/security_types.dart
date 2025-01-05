import 'dart:typed_data';

/// Nivo enkripcije koji se koristi
enum EncryptionLevel {
  basic, // AES-256
  advanced, // Post-quantum
  phoenix // Višestruka enkripcija sa dinamičkom promenom
}

/// Tip bezbednosnog događaja
enum SecurityEvent {
  attackDetected,
  protocolCompromised,
  keyCompromised,
  anomalyDetected,
  phoenixRegeneration
}

/// Model za bezbednosni ključ
class SecurityKey {
  final Uint8List key;
  final DateTime created;
  final DateTime expires;
  final EncryptionLevel level;
  final String keyId;
  bool isCompromised = false;

  SecurityKey({
    required this.key,
    required this.level,
    required this.keyId,
    DateTime? created,
    DateTime? expires,
  })  : created = created ?? DateTime.now(),
        expires = expires ?? DateTime.now().add(Duration(hours: 24));

  bool get isValid =>
      !isCompromised &&
      DateTime.now().isBefore(expires) &&
      DateTime.now().isAfter(created);
}

/// Model za enkriptovanu poruku
class EncryptedMessage {
  final Uint8List data;
  final String keyId;
  final EncryptionLevel level;
  final DateTime timestamp;
  final List<int> signature;
  final Map<String, dynamic> metadata;

  EncryptedMessage({
    required this.data,
    required this.keyId,
    required this.level,
    required this.signature,
    this.metadata = const {},
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'data': data.toList(),
        'keyId': keyId,
        'level': level.index,
        'timestamp': timestamp.toIso8601String(),
        'signature': signature,
        'metadata': metadata,
      };

  factory EncryptedMessage.fromJson(Map<String, dynamic> json) {
    return EncryptedMessage(
      data: Uint8List.fromList(List<int>.from(json['data'])),
      keyId: json['keyId'],
      level: EncryptionLevel.values[json['level']],
      timestamp: DateTime.parse(json['timestamp']),
      signature: List<int>.from(json['signature']),
      metadata: json['metadata'],
    );
  }
}

/// Model za bezbednosnu anomaliju
class SecurityAnomaly {
  final DateTime timestamp;
  final String sourceId;
  final SecurityEvent eventType;
  final Map<String, dynamic> details;
  final double severityScore;

  SecurityAnomaly({
    required this.sourceId,
    required this.eventType,
    required this.details,
    required this.severityScore,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
