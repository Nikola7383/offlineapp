import 'package:flutter/material.dart';
import '../logging/logger_service.dart';

class UiOptimizer {
  final LoggerService _logger;
  final _rebuildTracking = <String, _RebuildInfo>{};

  UiOptimizer({
    required LoggerService logger,
  }) : _logger = logger;

  void trackRebuild(String widgetId) {
    final now = DateTime.now();
    final info = _rebuildTracking[widgetId];

    if (info == null) {
      _rebuildTracking[widgetId] = _RebuildInfo(
        lastRebuild: now,
        count: 1,
      );
      return;
    }

    info.count++;

    final timeSinceLastRebuild = now.difference(info.lastRebuild);
    if (timeSinceLastRebuild.inMilliseconds < 16) {
      // 60fps target
      _logger.warning(
        'Frequent rebuilds detected for $widgetId: '
        '${info.count} rebuilds in ${timeSinceLastRebuild.inMilliseconds}ms',
      );
    }

    info.lastRebuild = now;
  }

  Widget Function(BuildContext) optimizeBuilder(
    String widgetId,
    Widget Function(BuildContext) builder,
  ) {
    return (context) {
      trackRebuild(widgetId);
      return builder(context);
    };
  }

  void resetTracking() {
    _rebuildTracking.clear();
  }
}

class _RebuildInfo {
  DateTime lastRebuild;
  int count;

  _RebuildInfo({
    required this.lastRebuild,
    required this.count,
  });
}
