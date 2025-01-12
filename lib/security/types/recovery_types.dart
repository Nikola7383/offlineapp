import 'package:flutter/material.dart';

/// Tip oporavka sistema
enum RecoveryType {
  /// Automatski oporavak
  automatic,

  /// Ručni oporavak
  manual,

  /// Oporavak uz pomoć korisnika
  userAssisted
}

/// Status oporavka
enum RecoveryStatus {
  /// Nije započet
  notStarted,

  /// U toku
  inProgress,

  /// Uspešno završen
  completed,

  /// Neuspešan
  failed
}

/// Detalji o procesu oporavka
class RecoveryDetails {
  final String id;
  final DateTime timestamp;
  final RecoveryType type;
  final RecoveryStatus status;
  final String description;
  final double progress;
  final List<String> logs;

  const RecoveryDetails({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.status,
    required this.description,
    required this.progress,
    required this.logs,
  });

  /// Kreira kopiju sa ažuriranim vrednostima
  RecoveryDetails copyWith({
    String? id,
    DateTime? timestamp,
    RecoveryType? type,
    RecoveryStatus? status,
    String? description,
    double? progress,
    List<String>? logs,
  }) {
    return RecoveryDetails(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      status: status ?? this.status,
      description: description ?? this.description,
      progress: progress ?? this.progress,
      logs: logs ?? this.logs,
    );
  }
}

/// Konfiguracija za oporavak
class RecoveryConfig {
  final Duration timeout;
  final int maxRetries;
  final bool requireUserConfirmation;
  final List<RecoveryType> allowedTypes;

  const RecoveryConfig({
    this.timeout = const Duration(minutes: 30),
    this.maxRetries = 3,
    this.requireUserConfirmation = true,
    this.allowedTypes = const [
      RecoveryType.automatic,
      RecoveryType.manual,
      RecoveryType.userAssisted
    ],
  });
}

class RecoveryStep {
  final String title;
  final String description;
  final RecoveryStatus status;
  final double progress;
  final VoidCallback? action;

  const RecoveryStep({
    required this.title,
    required this.description,
    this.status = RecoveryStatus.notStarted,
    this.progress = 0.0,
    this.action,
  });
}

class RecoveryContext {
  final BuildContext buildContext;
  final String processId;
  final DateTime startTime;
  final RecoveryType type;
  final List<String> logs;
  final Map<String, dynamic> metadata;

  const RecoveryContext({
    required this.buildContext,
    required this.processId,
    required this.startTime,
    required this.type,
    this.logs = const [],
    this.metadata = const {},
  });
}
