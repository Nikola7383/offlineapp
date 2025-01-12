import 'package:equatable/equatable.dart';

/// Tip događaja
enum EventType {
  emergency,
  system,
  user,
  network,
  security,
  maintenance,
}

/// Prioritet događaja
enum EventPriority {
  critical,
  high,
  medium,
  low,
}

/// Status događaja
enum EventStatus {
  created,
  processing,
  processed,
  completed,
  cancelled,
  failed,
  archived,
}

/// Model događaja
class Event extends Equatable {
  final String id;
  final EventType type;
  final EventPriority priority;
  final EventStatus status;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;
  final String? sourceId;
  final String? targetId;

  const Event({
    required this.id,
    required this.type,
    required this.priority,
    required this.status,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
    this.sourceId,
    this.targetId,
  });

  /// Kreira kopiju događaja sa novim vrednostima
  Event copyWith({
    String? id,
    EventType? type,
    EventPriority? priority,
    EventStatus? status,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
    String? sourceId,
    String? targetId,
  }) {
    return Event(
      id: id ?? this.id,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
      sourceId: sourceId ?? this.sourceId,
      targetId: targetId ?? this.targetId,
    );
  }

  /// Kreira događaj iz JSON mape
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      type: EventType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => EventType.system,
      ),
      priority: EventPriority.values.firstWhere(
        (e) => e.toString() == json['priority'],
        orElse: () => EventPriority.medium,
      ),
      status: EventStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => EventStatus.created,
      ),
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      sourceId: json['sourceId'] as String?,
      targetId: json['targetId'] as String?,
    );
  }

  /// Konvertuje događaj u JSON mapu
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'priority': priority.toString(),
      'status': status.toString(),
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
      'sourceId': sourceId,
      'targetId': targetId,
    };
  }

  @override
  List<Object?> get props => [
        id,
        type,
        priority,
        status,
        title,
        description,
        createdAt,
        updatedAt,
        metadata,
        sourceId,
        targetId,
      ];
}

abstract class Event {
  final String id;
  final DateTime timestamp;
  final String type;
  final Map<String, dynamic> data;

  Event({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.data,
  });
}

class EmergencyEvent extends Event {
  final int severity;
  final String source;

  EmergencyEvent({
    required String id,
    required DateTime timestamp,
    required String type,
    required Map<String, dynamic> data,
    required this.severity,
    required this.source,
  }) : super(
          id: id,
          timestamp: timestamp,
          type: type,
          data: data,
        );
}

class SecurityEvent extends Event {
  final int threatLevel;
  final String category;

  SecurityEvent({
    required String id,
    required DateTime timestamp,
    required String type,
    required Map<String, dynamic> data,
    required this.threatLevel,
    required this.category,
  }) : super(
          id: id,
          timestamp: timestamp,
          type: type,
          data: data,
        );
}
