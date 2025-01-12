class EmergencyOptions {
  final bool preserveEssentialFunctions;
  final bool enhancedSecurity;
  final bool limitedOperations;
  final Duration timeout;

  const EmergencyOptions({
    required this.preserveEssentialFunctions,
    required this.enhancedSecurity,
    required this.limitedOperations,
    this.timeout = const Duration(minutes: 30),
  });
}
