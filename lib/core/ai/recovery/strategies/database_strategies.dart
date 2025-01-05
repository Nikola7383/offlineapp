class DatabaseReconnectionStrategy extends RecoveryStrategy {
  static const MAX_ATTEMPTS = 3;
  static const DELAY_BETWEEN_ATTEMPTS = Duration(seconds: 5);

  @override
  Future<RecoveryResult> execute(HealthIssue issue) async {
    for (var attempt = 1; attempt <= MAX_ATTEMPTS; attempt++) {
      try {
        final db = GetIt.instance<DatabaseService>();

        // Pokušaj reconnect
        await db.disconnect();
        await Future.delayed(DELAY_BETWEEN_ATTEMPTS);
        await db.connect();

        // Proveri da li je konekcija uspešna
        if (await db.isConnected()) {
          return RecoveryResult(
            successful: true,
            message: 'Database reconnection successful',
            metrics: {'attempts': attempt},
          );
        }
      } catch (e) {
        if (attempt == MAX_ATTEMPTS) {
          return RecoveryResult(
            successful: false,
            message:
                'Database reconnection failed after $MAX_ATTEMPTS attempts',
            metrics: {'attempts': attempt},
          );
        }
      }
    }

    return RecoveryResult(
      successful: false,
      message: 'Database reconnection failed',
    );
  }
}

class DatabaseCleanupStrategy extends RecoveryStrategy {
  @override
  Future<RecoveryResult> execute(HealthIssue issue) async {
    try {
      final db = GetIt.instance<DatabaseService>();

      // Cleanup operacije
      await db.vacuum();
      await db.optimizeTables();
      await db.cleanupTempTables();

      return RecoveryResult(
        successful: true,
        message: 'Database cleanup successful',
        metrics: await db.getPerformanceMetrics(),
      );
    } catch (e) {
      return RecoveryResult(
        successful: false,
        message: 'Database cleanup failed: $e',
      );
    }
  }
}
