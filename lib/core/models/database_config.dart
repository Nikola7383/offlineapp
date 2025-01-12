/// Konfiguracija baze podataka
class DatabaseConfig {
  final String name;
  final String path;
  final bool encryptionEnabled;
  final String? encryptionKey;
  final int version;

  const DatabaseConfig({
    required this.name,
    required this.path,
    this.encryptionEnabled = false,
    this.encryptionKey,
    this.version = 1,
  });

  @override
  String toString() {
    return 'DatabaseConfig(name: $name, path: $path, version: $version, encryptionEnabled: $encryptionEnabled)';
  }
}
