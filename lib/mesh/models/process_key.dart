class ProcessKey {
  final String nodeId;
  final String processId;

  const ProcessKey({
    required this.nodeId,
    required this.processId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProcessKey &&
          runtimeType == other.runtimeType &&
          nodeId == other.nodeId &&
          processId == other.processId;

  @override
  int get hashCode => nodeId.hashCode ^ processId.hashCode;

  @override
  String toString() => 'ProcessKey{nodeId: $nodeId, processId: $processId}';
}
