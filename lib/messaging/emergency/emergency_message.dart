import 'dart:typed_data';
import 'emergency_message_system.dart' as emergency;

/// Poruka za hitne slučajeve
class EmergencyMessage {
  /// Sadržaj poruke
  final Uint8List content;

  /// Prioritet poruke
  final emergency.MessagePriority priority;

  /// Vreme kreiranja
  final DateTime timestamp;

  /// Kreira novu hitnu poruku
  EmergencyMessage({
    required this.content,
    required this.priority,
    required this.timestamp,
  });
}
