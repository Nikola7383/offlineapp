import 'package:secure_event_app/mesh/models/process_info.dart';
import 'package:secure_event_app/mesh/models/process_key.dart';

class ProcessStateChange {
  final ProcessKey key;
  final ProcessStatus oldStatus;
  final ProcessStatus newStatus;
  final DateTime timestamp;

  const ProcessStateChange({
    required this.key,
    required this.oldStatus,
    required this.newStatus,
    required this.timestamp,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProcessStateChange &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          oldStatus == other.oldStatus &&
          newStatus == other.newStatus &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      key.hashCode ^
      oldStatus.hashCode ^
      newStatus.hashCode ^
      timestamp.hashCode;

  @override
  String toString() =>
      'ProcessStateChange{key: $key, oldStatus: $oldStatus, newStatus: $newStatus, timestamp: $timestamp}';
}
