abstract class SecurityBaseComponent {
  final SecurityMemoryManager _memoryManager = SecurityMemoryManager();
  final ThreadSafeContainer _threadSafe = ThreadSafeContainer();
  final String componentId;

  SecurityBaseComponent() : componentId = Uuid().v4() {
    _initializeComponent();
  }

  void _initializeComponent() {
    // Registracija komponente u memory manageru
    _memoryManager.registerObject(componentId, this);

    // Inicijalizacija thread-safe containera
    _setupThreadSafety();
  }

  Future<T> safeOperation<T>(Future<T> Function() operation) async {
    return await _threadSafe.synchronized(operation);
  }

  void dispose() {
    _memoryManager.unregisterObject(componentId);
  }
}

// Primer implementacije u postojećim komponentama:
class SystemEncryptionManager extends SecurityBaseComponent {
  Future<EncryptedData> encryptData(dynamic data) async {
    return await safeOperation(() async {
      // Postojeća implementacija
      return await _encryptionEngine.encrypt(data);
    });
  }
}

class SystemAuditManager extends SecurityBaseComponent {
  Future<void> logEvent(AuditEvent event) async {
    await safeOperation(() async {
      // Postojeća implementacija
      await _auditLogger.log(event);
    });
  }
}
