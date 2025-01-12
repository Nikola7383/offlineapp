class DatabaseException implements Exception {
  final String message;
  final String operation;
  final String table;

  DatabaseException(
    this.message, {
    required this.operation,
    required this.table,
  });

  @override
  String toString() =>
      'DatabaseException: $message (Operation: $operation, Table: $table)';
}
