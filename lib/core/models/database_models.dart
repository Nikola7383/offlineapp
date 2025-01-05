/// Tipovi batch operacija
enum BatchOperationType { set, delete }

/// Model za batch operacije
class BatchOperation {
  final BatchOperationType type;
  final String key;
  final dynamic value;

  const BatchOperation({
    required this.type,
    required this.key,
    this.value,
  });
}

/// Model za database config
class DatabaseConfig {
  final String name;
  final String path;
  final bool encryptionEnabled;
  final String? encryptionKey;
  final int schemaVersion;

  const DatabaseConfig({
    required this.name,
    required this.path,
    this.encryptionEnabled = true,
    this.encryptionKey,
    this.schemaVersion = 1,
  });
}
