abstract class IService {
  bool get isInitialized;

  Future<void> initialize();
  Future<void> dispose();
}
