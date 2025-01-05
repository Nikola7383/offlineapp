class SystemStatus {
  final bool isIntegrated;
  final List<ComponentStatus> components;
  final Metrics metrics;
  final SystemHealth health;

  SystemStatus({
    required this.isIntegrated,
    required this.components,
    required this.metrics,
    required this.health,
  });

  bool get isOperational =>
      isIntegrated && components.every((c) => c.isOperational);

  List<ComponentStatus> get failedComponents =>
      components.where((c) => !c.isOperational).toList();
}
