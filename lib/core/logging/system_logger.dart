class SystemLogger implements LoggerService {
  static const String LOG_FILE = 'system_logs.enc';
  final SecurityService _security;
  final StorageService _storage;
  bool _initialized = false;

  SystemLogger({
    required SecurityService security,
    required StorageService storage,
  }) : _security = security,
       _storage = storage;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Kreiraj encrypted log file ako ne postoji
      if (!await _storage.exists(LOG_FILE)) {
        await _storage.create(LOG_FILE, encrypted: true);
      }

      // Verifikuj pristup
      await _testLogAccess();
      
      _initialized = true;
      
      await info('Logger system initialized successfully');
    } catch (e) {
      throw LoggerException('Failed to initialize logger: $e');
    }
  }

  @override
  Future<void> log(String level, String message) async {
    if (!_initialized) await initialize();

    final logEntry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      encrypted: true
    );

    await _writeLog(logEntry);
  }

  @override
  Future<void> error(String message) async {
    await log('ERROR', message);
  }

  @override
  Future<void> info(String message) async {
    await log('INFO', message);
  }

  @override
  Future<void> debug(String message) async {
    await log('DEBUG', message);
  }

  Future<void> _writeLog(LogEntry entry) async {
    try {
      final encrypted = await _security.encrypt(entry.toString());
      await _storage.append(LOG_FILE, encrypted);
    } catch (e) {
      // U slučaju greške, pokušaj pisati u backup
      await _writeToBackup(entry);
    }
  }
} 