import 'dart:async';
import '../utils/resource_manager.dart';
import 'logger_service.dart';

class CleanupService {
  final ResourceManager _resourceManager;
  final LoggerService _logger;
  Timer? _cleanupTimer;

  CleanupService({
    required ResourceManager resourceManager,
    required LoggerService logger,
  })  : _resourceManager = resourceManager,
        _logger = logger;

  void initialize() {
    _startPeriodicCleanup();
  }

  void _startPeriodicCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 30),
      (_) => _performCleanup(),
    );
  }

  Future<void> _performCleanup() async {
    try {
      await _resourceManager.disposeAll();
      _logger.info('Periodic cleanup completed successfully');
    } catch (e, stack) {
      _logger.error('Error during periodic cleanup', e, stack);
    }
  }

  Future<void> dispose() async {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    await _resourceManager.disposeAll();
  }
}
