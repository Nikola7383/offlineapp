class ThreadSafeContainer {
  static final _lock = Lock();

  static Future<T> synchronized<T>(Future<T> Function() computation) async {
    return await _lock.synchronized(computation);
  }

  static Future<void> guardedWrite(Future<void> Function() operation) async {
    await synchronized(operation);
  }

  static Future<T> guardedRead<T>(Future<T> Function() operation) async {
    return await synchronized(operation);
  }
}

// Primer upotrebe u SecurityLogger:
class SecurityLogger {
  Future<void> logEntry(LogEntry entry) async {
    await ThreadSafeContainer.guardedWrite(() async {
      _logBuffer.add(entry);
      await _logStream.add(entry);
    });
  }
}
