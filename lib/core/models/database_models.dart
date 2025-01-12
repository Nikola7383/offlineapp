import 'package:freezed_annotation/freezed_annotation.dart';

part 'database_models.freezed.dart';
part 'database_models.g.dart';

/// Konfiguracija baze podataka
@freezed
class DatabaseConfig with _$DatabaseConfig {
  const factory DatabaseConfig({
    required String name,
    required String path,
    @Default(false) bool encryptionEnabled,
    String? encryptionKey,
    @Default(1) int schemaVersion,
  }) = _DatabaseConfig;

  factory DatabaseConfig.fromJson(Map<String, dynamic> json) =>
      _$DatabaseConfigFromJson(json);
}

/// Tip operacije za batch processing
enum BatchOperationType {
  set,
  delete,
}

/// Operacija za batch processing
@freezed
class BatchOperation with _$BatchOperation {
  const factory BatchOperation({
    required BatchOperationType type,
    required String key,
    dynamic value,
  }) = _BatchOperation;

  factory BatchOperation.fromJson(Map<String, dynamic> json) =>
      _$BatchOperationFromJson(json);
}
