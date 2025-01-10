import 'dart:async';
import 'dart:typed_data';
import '../models/node.dart';

/// Interfejs za transport poruka kroz različite kanale komunikacije
abstract class MessageTransport {
  /// Inicijalizuje transport
  Future<void> initialize();

  /// Šalje podatke određenom čvoru
  Future<void> sendData(
    String targetNodeId,
    Uint8List data,
    TransportOptions options,
  );

  /// Šalje podatke svim susednim čvorovima
  Future<void> broadcast(
    Uint8List data,
    TransportOptions options,
  );

  /// Sluša dolazne podatke
  Stream<TransportMessage> get messageStream;

  /// Vraća listu dostupnih čvorova
  Future<List<Node>> discoverNodes();

  /// Proverava da li je čvor dostupan
  Future<bool> isNodeAvailable(String nodeId);

  /// Vraća trenutni status transporta
  TransportStatus get status;

  /// Čisti resurse
  Future<void> dispose();
}

/// Opcije za slanje poruka
class TransportOptions {
  /// Prioritet poruke
  final TransportPriority priority;

  /// Maksimalan broj pokušaja slanja
  final int maxRetries;

  /// Timeout za slanje
  final Duration timeout;

  /// Da li je potrebna potvrda prijema
  final bool requireAck;

  /// Dodatne opcije specifične za transport
  final Map<String, dynamic>? metadata;

  const TransportOptions({
    this.priority = TransportPriority.normal,
    this.maxRetries = 3,
    this.timeout = const Duration(seconds: 30),
    this.requireAck = true,
    this.metadata,
  });
}

/// Prioriteti transporta
enum TransportPriority {
  /// Nizak prioritet
  low,

  /// Normalan prioritet
  normal,

  /// Visok prioritet
  high,

  /// Kritičan prioritet
  critical,
}

/// Status transporta
enum TransportStatus {
  /// Nije inicijalizovan
  notInitialized,

  /// Inicijalizacija u toku
  initializing,

  /// Spreman za rad
  ready,

  /// Privremeno nedostupan
  temporarilyUnavailable,

  /// Trajno nedostupan
  permanentlyUnavailable,

  /// Greška
  error,
}

/// Poruka primljena preko transporta
class TransportMessage {
  /// ID izvornog čvora
  final String sourceNodeId;

  /// Primljeni podaci
  final Uint8List data;

  /// Vreme prijema
  final DateTime timestamp;

  /// Jačina signala (0.0 - 1.0)
  final double? signalStrength;

  /// Dodatni metapodaci
  final Map<String, dynamic>? metadata;

  const TransportMessage({
    required this.sourceNodeId,
    required this.data,
    required this.timestamp,
    this.signalStrength,
    this.metadata,
  });
}

/// Greška u transportu
class TransportException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const TransportException(
    this.message, {
    this.code,
    this.details,
  });

  @override
  String toString() =>
      'TransportException: $message${code != null ? ' ($code)' : ''}';
}

/// Interfejs za praćenje statistike transporta
abstract class TransportStats {
  /// Ukupan broj poslatih poruka
  int get totalMessagesSent;

  /// Ukupan broj primljenih poruka
  int get totalMessagesReceived;

  /// Broj neuspelih slanja
  int get failedDeliveries;

  /// Prosečno vreme slanja (ms)
  double get averageLatency;

  /// Prosečna jačina signala (0.0 - 1.0)
  double get averageSignalStrength;

  /// Stopa uspešnosti slanja (0.0 - 1.0)
  double get deliverySuccessRate;

  /// Resetuje statistiku
  void reset();
}
