import 'dart:async';
import 'package:flutter/foundation.dart';
import '../logging/logger_service.dart';
import '../config/app_config.dart';

class MemoryOptimizer {
  final LoggerService _logger;
  Timer? _optimizationTimer;
  final Map<String, WeakReference<Object>> _cache = {};

  MemoryOptimizer({
    required LoggerService logger,
  }) : _logger = logger {
    _startOptimizationTimer();
  }

  void _startOptimizationTimer() {
    _optimizationTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _performOptimization(),
    );
  }

  Future<void> _performOptimization() async {
    try {
      // Očisti cache
      _cache.removeWhere((_, value) => value.target == null);

      // Proveri memory usage
      final memoryInfo = await _getMemoryInfo();
      if (memoryInfo > AppConfig.maxMemoryUsage) {
        _logger.warning(
            'High memory usage detected: ${memoryInfo ~/ 1024 / 1024}MB');
        await _reduceMemoryUsage();
      }
    } catch (e) {
      _logger.error('Memory optimization failed', e);
    }
  }

  Future<void> _reduceMemoryUsage() async {
    // Očisti cache
    _cache.clear();

    // Pozovi GC
    await Future.delayed(const Duration(seconds: 1));

    // Log rezultate
    final newMemoryInfo = await _getMemoryInfo();
    _logger.info(
        'Memory usage after optimization: ${newMemoryInfo ~/ 1024 / 1024}MB');
  }

  Future<int> _getMemoryInfo() async {
    // Implementacija za dobijanje trenutne memorijske potrošnje
    return Future.value(100 * 1024 * 1024); // Mock 100MB
  }

  void cacheObject(String key, Object object) {
    _cache[key] = WeakReference(object);
  }

  T? getCachedObject<T>(String key) {
    final ref = _cache[key]?.target;
    return ref is T ? ref : null;
  }

  void dispose() {
    _optimizationTimer?.cancel();
    _cache.clear();
  }
}
