class MemoryMetrics {
  final String key;
  int activeReferences = 0;
  int peakReferences = 0;
  final DateTime createdAt;
  DateTime lastAccessed;
  int cleanupAttempts = 0;

  MemoryMetrics(this.key)
      : createdAt = DateTime.now(),
        lastAccessed = DateTime.now();

  void addReference() {
    activeReferences++;
    peakReferences = max(peakReferences, activeReferences);
    lastAccessed = DateTime.now();
  }

  void removeReference() {
    activeReferences = max(0, activeReferences - 1);
    lastAccessed = DateTime.now();
  }

  Duration get age => DateTime.now().difference(createdAt);

  bool get isPotentialLeak {
    final unusedDuration = DateTime.now().difference(lastAccessed);
    return activeReferences > 0 &&
        unusedDuration > Duration(minutes: 30) &&
        activeReferences >= peakReferences;
  }

  bool get shouldForceCleanup => isPotentialLeak && cleanupAttempts < 3;

  void forceCleanup() {
    activeReferences = 0;
    cleanupAttempts++;
    lastAccessed = DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'activeReferences': activeReferences,
      'peakReferences': peakReferences,
      'age': age.inMinutes,
      'lastAccessed': lastAccessed.millisecondsSinceEpoch,
      'cleanupAttempts': cleanupAttempts,
    };
  }
}
