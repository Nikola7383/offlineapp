import 'dart:typed_data';
import 'base_service.dart';
import '../models/message.dart';
import '../models/encrypted_message.dart';
import '../models/message_types.dart';

/// Interfejs za messaging servis
abstract class IMessagingService implements IAsyncService {
  /// Šalje poruku
  Future<void> send(Message message);

  /// Prima poruku
  Future<Message> receive(EncryptedMessage message);

  /// Pretplaćuje se na temu
  Stream<Message> subscribe(String topic);

  /// Otkazuje pretplatu
  Future<void> unsubscribe(String topic);

  /// Vraća sve poruke za temu
  Future<List<Message>> getMessagesByTopic(String topic);

  /// Vraća sve poruke za korisnika
  Future<List<Message>> getMessagesForUser(String userId);

  /// Vraća sve poruke po tipu
  Future<List<Message>> getMessagesByType(String type);

  /// Vraća sve poruke po prioritetu
  Future<List<Message>> getMessagesByPriority(MessagePriority priority);

  /// Briše poruku
  Future<void> deleteMessage(String messageId);

  /// Briše sve poruke
  Future<void> deleteAllMessages();

  /// Vraća statistiku poruka
  Future<MessageStats> getMessageStats();

  /// Vraća status servisa
  Future<MessagingServiceStatus> getStatus();
}

/// Interfejs za transport poruka
abstract class IMessageTransport implements IAsyncService {
  /// Šalje raw poruku
  Future<void> sendRaw(Uint8List data, String destination);

  /// Prima raw poruke
  Stream<TransportMessage> get incomingMessages;

  /// Vraća status konekcije
  Future<TransportStatus> checkConnection();

  /// Stream za praćenje statusa konekcije
  Stream<TransportStatus> get connectionStatus;

  /// Vraća dostupne rute
  Future<List<RouteInfo>> getRoutes();
}

/// Transport poruka
class TransportMessage {
  /// Raw podaci
  final Uint8List data;

  /// Izvor poruke
  final String source;

  /// Vreme prijema
  final DateTime receivedAt;

  /// Metadata transporta
  final Map<String, dynamic> metadata;

  /// Kreira novu transport poruku
  TransportMessage({
    required this.data,
    required this.source,
    required this.receivedAt,
    this.metadata = const {},
  });
}

/// Informacije o ruti
class RouteInfo {
  /// ID rute
  final String id;

  /// Tip rute
  final String type;

  /// Latencija
  final Duration latency;

  /// Status rute
  final RouteStatus status;

  /// Metadata rute
  final Map<String, dynamic> metadata;

  /// Kreira nove informacije o ruti
  RouteInfo({
    required this.id,
    required this.type,
    required this.latency,
    required this.status,
    this.metadata = const {},
  });
}

/// Statistika poruka
class MessageStats {
  /// Ukupan broj poruka
  final int totalMessages;

  /// Broj poruka po tipu
  final Map<String, int> messagesByType;

  /// Broj poruka po prioritetu
  final Map<MessagePriority, int> messagesByPriority;

  /// Prosečno vreme isporuke
  final Duration averageDeliveryTime;

  /// Stopa uspešnosti
  final double successRate;

  const MessageStats({
    required this.totalMessages,
    required this.messagesByType,
    required this.messagesByPriority,
    required this.averageDeliveryTime,
    required this.successRate,
  });
}

/// Status messaging servisa
class MessagingServiceStatus {
  /// Da li je servis aktivan
  final bool isActive;

  /// Status transporta
  final TransportStatus transportStatus;

  /// Status rute
  final RouteStatus routeStatus;

  /// Broj aktivnih pretplata
  final int activeSubscriptions;

  /// Veličina keša
  final int cacheSize;

  /// Vreme poslednje aktivnosti
  final DateTime lastActivity;

  const MessagingServiceStatus({
    required this.isActive,
    required this.transportStatus,
    required this.routeStatus,
    required this.activeSubscriptions,
    required this.cacheSize,
    required this.lastActivity,
  });

  /// Da li je servis zdrav
  bool get isHealthy =>
      isActive &&
      transportStatus == TransportStatus.connected &&
      routeStatus == RouteStatus.active;
}
