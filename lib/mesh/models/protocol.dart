/// Protokoli koji se koriste za komunikaciju između čvorova
enum Protocol {
  /// Bluetooth protokol
  bluetooth,

  /// WiFi Direct protokol
  wifiDirect,

  /// Zvučni protokol
  sound,

  /// LoRa protokol
  lora,

  /// Mesh protokol
  mesh,

  /// Cellular protokol
  cellular,

  /// NFC protokol
  nfc,

  /// Infrared protokol
  infrared,

  /// Zigbee protokol
  zigbee,

  /// Thread protokol
  thread,
}

class ProtocolScore {
  final Protocol protocol;
  final double score;

  ProtocolScore(this.protocol, this.score);
}
